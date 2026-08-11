import Foundation
import Combine
import AppKit

public class BreakTimerEngine: ObservableObject {
    @Published public var appState: AppState
    @Published public var preferences: UserPreferences

    public let contextMonitor: ContextMonitor
    public let overlayManager: OverlayWindowManager
    public let visionEngine: VisionAnalyticsEngine

    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()

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
        startEngine()
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

    public func startEngine() {
        timer?.invalidate()
        appState.timerState = .working
        appState.secondsRemaining = preferences.microBreakIntervalMinutes * 60
        appState.totalSecondsForCurrentState = appState.secondsRemaining

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    private func tick() {
        // 1. Check Meeting Shield override
        if preferences.enableMeetingShield && contextMonitor.isMeetingActive {
            if appState.timerState != .pausedMeeting {
                appState.timerState = .pausedMeeting
                overlayManager.dismissToast()
            }
            return // Freeze countdown while call is active
        }

        // 2. Check AFK Idle override
        if preferences.enableIdleDetection && contextMonitor.isUserIdle {
            if appState.timerState != .pausedIdle {
                appState.timerState = .pausedIdle
                overlayManager.dismissToast()
            }
            return // Freeze countdown while user is away
        }

        // Return state to working if paused
        if appState.timerState == .pausedMeeting || appState.timerState == .pausedIdle {
            appState.timerState = .working
        }

        // Handle Active State Countdowns
        switch appState.timerState {
        case .working:
            if appState.secondsRemaining > 0 {
                appState.secondsRemaining -= 1

                // Check pre-break warning trigger
                if preferences.enablePreBreakToast && appState.secondsRemaining == preferences.preBreakToastSeconds {
                    triggerPreBreakWarning()
                }
            } else {
                startBreakRoutine(protocol: appState.currentProtocol)
            }

        case .preBreakWarning:
            if appState.secondsRemaining > 0 {
                appState.secondsRemaining -= 1
            } else {
                startBreakRoutine(protocol: appState.currentProtocol)
            }

        case .inBreak:
            if appState.breakSecondsRemaining > 0 {
                appState.breakSecondsRemaining -= 1
            } else {
                completeBreakRoutine()
            }

        default:
            break
        }
    }

    public func triggerPreBreakWarning() {
        appState.timerState = .preBreakWarning
        if preferences.enableSoundEffects {
            NSSound.beep()
        }

        overlayManager.showPreBreakToast(
            appState: appState,
            onStartNow: { [weak self] in
                guard let self = self else { return }
                self.startBreakRoutine(protocol: self.appState.currentProtocol)
            },
            onSnooze: { [weak self] in
                self?.snoozeBreak(minutes: 5)
            }
        )
    }

    public func startBreakRoutine(protocol targetProtocol: OphthalmicProtocol) {
        overlayManager.dismissToast()

        appState.currentProtocol = targetProtocol
        appState.timerState = .inBreak
        appState.breakTotalSeconds = targetProtocol.defaultDurationSeconds
        appState.breakSecondsRemaining = targetProtocol.defaultDurationSeconds

        if preferences.enableSoundEffects {
            NSSound(named: "Glass")?.play()
        }

        overlayManager.presentBreakOverlay(
            appState: appState,
            preferences: preferences,
            onComplete: { [weak self] in
                self?.completeBreakRoutine()
            },
            onSnooze: { [weak self] in
                self?.snoozeBreak(minutes: 5)
            }
        )
    }

    public func completeBreakRoutine() {
        overlayManager.dismissBreakOverlay()

        appState.breaksCompletedToday += 1
        appState.totalRelaxationSecondsToday += appState.breakTotalSeconds
        appState.estimatedTearFilmScore = min(100, appState.estimatedTearFilmScore + 2)

        if preferences.enableSoundEffects {
            NSSound(named: "Hero")?.play()
        }

        // Rotate to next logical ophthalmic protocol
        rotateProtocol()

        // Reset timer back to work interval
        startEngine()
    }

    public func snoozeBreak(minutes: Int = 5) {
        overlayManager.dismissAllOverlays()

        appState.timerState = .working
        appState.secondsRemaining = minutes * 60
        appState.totalSecondsForCurrentState = appState.secondsRemaining
    }

    private func rotateProtocol() {
        let all = OphthalmicProtocol.allCases
        if let idx = all.firstIndex(of: appState.currentProtocol) {
            let nextIdx = (idx + 1) % all.count
            appState.currentProtocol = all[nextIdx]
        }
    }
}
