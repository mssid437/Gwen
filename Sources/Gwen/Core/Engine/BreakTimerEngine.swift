import Foundation
import Combine
import AppKit

/// Writes debug output to stderr (always unbuffered, captured by terminal)
private func debugLog(_ msg: String) {
    let line = "[Gwen] \(msg)\n"
    FileHandle.standardError.write(Data(line.utf8))
}

public class BreakTimerEngine: ObservableObject {
    @Published public var appState: AppState
    @Published public var preferences: UserPreferences
    
    public let contextMonitor: ContextMonitor
    public let overlayManager: OverlayWindowManager
    public let visionEngine: VisionAnalyticsEngine
    
    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    // Protocol scheduling: track last completion time for each protocol
    private var lastProtocolCompletion: [OphthalmicProtocol: Date] = [:]
    
    public init(
        appState: AppState,
        preferences: UserPreferences,
        contextMonitor: ContextMonitor = ContextMonitor(),
        overlayManager: OverlayWindowManager = OverlayWindowManager(),
        visionEngine: VisionAnalyticsEngine = VisionAnalyticsEngine()
    ) {
        self.appState = appState
        self.preferences = preferences
        self.contextMonitor = contextMonitor
        self.overlayManager = overlayManager
        self.visionEngine = visionEngine
        
        setupSubscriptions()
        startWorkTimer()
    }
    
    private func setupSubscriptions() {
        // Bind vision engine metrics to appState when camera mode is enabled
        visionEngine.$blinksPerMinute
            .assign(to: \.blinksPerMinute, on: appState)
            .store(in: &cancellables)

        visionEngine.$postureAngleDegrees
            .assign(to: \.postureAngleDegrees, on: appState)
            .store(in: &cancellables)

        visionEngine.$isPostureOptimal
            .assign(to: \.isPostureOptimal, on: appState)
            .store(in: &cancellables)

        visionEngine.$isBlinkDeficient
            .assign(to: \.isBlinkRateDeficient, on: appState)
            .store(in: &cancellables)

        preferences.$enableVisionTracking
            .sink { [weak self] enabled in
                if enabled {
                    self?.visionEngine.startSession()
                } else {
                    self?.visionEngine.stopSession()
                }
            }
            .store(in: &cancellables)
    }
    
    // IMPORTANT: This only starts/restarts the 1-second tick timer and sets state to working.
    // It does NOT dismiss overlays.
    public func startWorkTimer() {
        timer?.invalidate()
        timer = nil
        appState.timerState = .working
        appState.secondsRemaining = preferences.microBreakIntervalMinutes * 60
        appState.totalSecondsForCurrentState = appState.secondsRemaining
        
        debugLog("🟢 startWorkTimer: interval=\(appState.secondsRemaining)s")
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }
    
    private func tick() {
        // CRITICAL: Respect manual pause — do nothing
        if appState.timerState == .manuallyPaused { return }
        
        // Meeting shield check
        if preferences.enableMeetingShield && contextMonitor.isMeetingActive {
            if appState.timerState != .pausedMeeting {
                debugLog("⏸ Meeting detected, pausing")
                appState.timerState = .pausedMeeting
                overlayManager.dismissToast()
            }
            return
        }
        
        // AFK idle check
        if preferences.enableIdleDetection && contextMonitor.isUserIdle {
            if appState.timerState != .pausedIdle {
                debugLog("⏸ User idle, pausing")
                appState.timerState = .pausedIdle
                overlayManager.dismissToast()
            }
            return
        }
        
        // Auto-recover from AFK/Meeting pauses (NOT manual pause)
        if appState.timerState == .pausedMeeting || appState.timerState == .pausedIdle {
            debugLog("▶️ Recovering from pause -> working")
            appState.timerState = .working
        }
        
        // Track total work time
        if appState.timerState == .working || appState.timerState == .preBreakWarning {
            appState.totalWorkSecondsToday += 1
        }
        
        switch appState.timerState {
        case .working:
            if appState.secondsRemaining > 0 {
                appState.secondsRemaining -= 1
                // Log countdown every 5 seconds to show ticking
                if appState.secondsRemaining % 5 == 0 {
                    debugLog("⏱ tick: \(appState.secondsRemaining)s remaining")
                }
                if preferences.enablePreBreakToast && appState.secondsRemaining == preferences.preBreakToastSeconds {
                    triggerPreBreakWarning()
                }
            } else {
                debugLog("⏰ Timer hit zero, starting break")
                beginBreak(protocol: nextDueProtocol())
            }
            
        case .preBreakWarning:
            if appState.secondsRemaining > 0 {
                appState.secondsRemaining -= 1
            } else {
                debugLog("⏰ Pre-break warning expired, starting break")
                beginBreak(protocol: nextDueProtocol())
            }
            
        case .inBreak:
            if appState.breakSecondsRemaining > 0 {
                appState.breakSecondsRemaining -= 1
                // Log break countdown every 5 seconds
                if appState.breakSecondsRemaining % 5 == 0 {
                    debugLog("🔵 break tick: \(appState.breakSecondsRemaining)s remaining")
                }
            } else {
                debugLog("✅ Break timer hit zero, finishing break")
                finishBreak()
            }
            
        default:
            break
        }
    }
    
    // Determine which protocol is most overdue
    private func nextDueProtocol() -> OphthalmicProtocol {
        let now = Date()
        var mostOverdue: OphthalmicProtocol = .microBreak
        var maxOverdue: TimeInterval = -1
        
        for proto in OphthalmicProtocol.allCases {
            let lastDone = lastProtocolCompletion[proto] ?? sessionStartDate
            let interval = TimeInterval(proto.defaultIntervalMinutes * 60)
            let overdue = now.timeIntervalSince(lastDone) - interval
            if overdue > maxOverdue {
                maxOverdue = overdue
                mostOverdue = proto
            }
        }
        debugLog("📋 nextDueProtocol: \(mostOverdue.rawValue)")
        return mostOverdue
    }
    
    private var sessionStartDate = Date()
    
    private func triggerPreBreakWarning() {
        debugLog("⚠️ triggerPreBreakWarning")
        appState.timerState = .preBreakWarning
        if preferences.enableSoundEffects { NSSound.beep() }
        
        overlayManager.showPreBreakToast(
            appState: appState,
            onStartNow: { [weak self] in
                debugLog("👆 User tapped Start Now on toast")
                self?.beginBreak(protocol: self?.nextDueProtocol() ?? .microBreak)
            },
            onSnooze: { [weak self] in
                debugLog("💤 User tapped Snooze on toast")
                self?.snooze(minutes: 5)
            }
        )
    }
    
    // CRITICAL: This is the only method that shows the break overlay
    public func beginBreak(protocol targetProtocol: OphthalmicProtocol) {
        debugLog("🔵 beginBreak called: proto=\(targetProtocol.rawValue) state=\(appState.timerState.rawValue)")
        guard appState.timerState != .inBreak else {
            debugLog("⛔ beginBreak BLOCKED: already in break")
            return
        }
        
        overlayManager.dismissToast()
        
        appState.currentProtocol = targetProtocol
        appState.timerState = .inBreak
        appState.breakTotalSeconds = targetProtocol.defaultDurationSeconds
        appState.breakSecondsRemaining = targetProtocol.defaultDurationSeconds
        
        if preferences.enableSoundEffects {
            NSSound(named: "Glass")?.play()
        }
        
        debugLog("🔵 beginBreak: overlay presenting, breakSeconds=\(targetProtocol.defaultDurationSeconds)")
        
        overlayManager.presentBreakOverlay(
            appState: appState,
            preferences: preferences,
            onComplete: { [weak self] in
                debugLog("👆 User tapped Skip/Complete on overlay")
                self?.finishBreak()
            },
            onSnooze: { [weak self] in
                debugLog("💤 User tapped Snooze on overlay")
                self?.snooze(minutes: 5)
            }
        )
    }
    
    // CRITICAL: This is the only method that ends a break
    public func finishBreak() {
        debugLog("🟡 finishBreak called: state=\(appState.timerState.rawValue)")
        guard appState.timerState == .inBreak else {
            debugLog("⛔ finishBreak BLOCKED: state is \(appState.timerState.rawValue), not inBreak")
            return
        }
        
        // IMMEDIATELY change state so tick() and button presses cannot re-enter
        appState.timerState = .working
        appState.secondsRemaining = preferences.microBreakIntervalMinutes * 60
        appState.totalSecondsForCurrentState = appState.secondsRemaining
        
        // Record completion
        appState.breaksCompletedToday += 1
        appState.totalRelaxationSecondsToday += appState.breakTotalSeconds
        appState.estimatedTearFilmScore = min(100, appState.estimatedTearFilmScore + 2)
        lastProtocolCompletion[appState.currentProtocol] = Date()
        
        debugLog("🟡 finishBreak: state->working, breaks=\(appState.breaksCompletedToday), nextInterval=\(appState.secondsRemaining)s")
        
        if preferences.enableSoundEffects {
            NSSound(named: "Hero")?.play()
        }
        
        // Dismiss overlay
        overlayManager.dismissBreakOverlay {
            debugLog("🟡 finishBreak: overlay dismissed")
        }
    }
    
    public func snooze(minutes: Int = 5) {
        debugLog("💤 snooze called: state=\(appState.timerState.rawValue)")
        guard appState.timerState == .inBreak || appState.timerState == .preBreakWarning else {
            debugLog("⛔ snooze BLOCKED: state is \(appState.timerState.rawValue)")
            return
        }
        
        // IMMEDIATELY change state
        appState.timerState = .working
        appState.secondsRemaining = minutes * 60
        appState.totalSecondsForCurrentState = minutes * 60
        
        debugLog("💤 snooze: state->working, snoozeSeconds=\(minutes * 60)")
        
        overlayManager.dismissAllOverlays()
    }
    
    // Called by the UI pause button
    public func togglePause() {
        debugLog("⏯ togglePause called: current state=\(appState.timerState.rawValue)")
        if appState.timerState == .manuallyPaused {
            // Resume
            debugLog("⏯ togglePause: resuming -> .working")
            appState.timerState = .working
        } else if appState.timerState == .working || appState.timerState == .preBreakWarning {
            // Pause
            debugLog("⏯ togglePause: pausing -> .manuallyPaused")
            appState.timerState = .manuallyPaused
            overlayManager.dismissToast()
        } else {
            debugLog("⏯ togglePause: ignored (state=\(appState.timerState.rawValue))")
        }
    }
}
