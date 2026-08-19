import XCTest
@testable import Gwen

final class GwenTests: XCTestCase {
    
    var appState: AppState!
    var preferences: UserPreferences!
    var engine: BreakTimerEngine!
    
    override func setUp() {
        super.setUp()
        appState = AppState()
        preferences = UserPreferences()
        engine = BreakTimerEngine(
            appState: appState,
            preferences: preferences,
            contextMonitor: ContextMonitor(),
            overlayManager: OverlayWindowManager(),
            visionEngine: VisionAnalyticsEngine()
        )
    }
    
    override func tearDown() {
        engine = nil
        appState = nil
        preferences = nil
        super.tearDown()
    }
    
    // MARK: - 1. Pause & Resume Functionality
    func testPauseAndResumeToggle() {
        // Initially in .working state
        XCTAssertEqual(appState.timerState, .working)
        
        // Toggle pause -> should become .manuallyPaused
        engine.togglePause()
        XCTAssertEqual(appState.timerState, .manuallyPaused, "togglePause() should transition from .working to .manuallyPaused")
        
        // Second toggle -> should resume to .working
        engine.togglePause()
        XCTAssertEqual(appState.timerState, .working, "togglePause() should transition from .manuallyPaused back to .working")
    }
    
    func testPauseIgnoredDuringBreak() {
        // Start a break
        engine.beginBreak(protocol: .microBreak)
        XCTAssertEqual(appState.timerState, .inBreak)
        
        // Toggling pause while in a break routine should be ignored
        engine.togglePause()
        XCTAssertEqual(appState.timerState, .inBreak, "togglePause() should be ignored while inside an active break")
    }
    
    // MARK: - 2. Break Execution & Completion Flow
    func testBeginBreakAndFinishBreak() {
        let initialBreaks = appState.breaksCompletedToday
        let initialRelaxation = appState.totalRelaxationSecondsToday
        let initialTearScore = appState.estimatedTearFilmScore
        
        // Begin Micro-Break (20s)
        engine.beginBreak(protocol: .microBreak)
        XCTAssertEqual(appState.timerState, .inBreak)
        XCTAssertEqual(appState.currentProtocol, .microBreak)
        XCTAssertEqual(appState.breakSecondsRemaining, 20)
        XCTAssertEqual(appState.breakTotalSeconds, 20)
        
        // Finish break
        engine.finishBreak()
        XCTAssertEqual(appState.timerState, .working, "State should immediately return to .working on break completion")
        XCTAssertEqual(appState.breaksCompletedToday, initialBreaks + 1, "Completed breaks count should increment")
        XCTAssertEqual(appState.totalRelaxationSecondsToday, initialRelaxation + 20, "Relaxation time should increase by break duration")
        XCTAssertGreaterThanOrEqual(appState.estimatedTearFilmScore, initialTearScore, "Tear film score should increase")
    }
    
    func testFinishBreakIsIdempotent() {
        engine.beginBreak(protocol: .microBreak)
        XCTAssertEqual(appState.timerState, .inBreak)
        
        // First finish call
        engine.finishBreak()
        XCTAssertEqual(appState.timerState, .working)
        let breaksAfterFirst = appState.breaksCompletedToday
        
        // Second finish call immediately after should be a no-op (guarded against double-invocation)
        engine.finishBreak()
        XCTAssertEqual(appState.breaksCompletedToday, breaksAfterFirst, "Double finishBreak should not double count")
    }
    
    // MARK: - 3. Snooze Functionality
    func testSnoozeDuringBreak() {
        engine.beginBreak(protocol: .microBreak)
        XCTAssertEqual(appState.timerState, .inBreak)
        
        // Snooze for 5 minutes
        engine.snooze(minutes: 5)
        XCTAssertEqual(appState.timerState, .working, "Snooze should return state to .working")
        XCTAssertEqual(appState.secondsRemaining, 300, "Seconds remaining should be 300 (5 mins)")
        XCTAssertEqual(appState.totalSecondsForCurrentState, 300)
    }
    
    func testSnoozeIgnoredWhenWorking() {
        XCTAssertEqual(appState.timerState, .working)
        let previousSeconds = appState.secondsRemaining
        
        // Snoozing while already working should be safely ignored
        engine.snooze(minutes: 5)
        XCTAssertEqual(appState.secondsRemaining, previousSeconds, "Snooze when already working should not alter timer")
    }
    
    // MARK: - 4. Protocol Definitions & Integrity
    func testAllFiveOphthalmicProtocols() {
        let allProtocols = OphthalmicProtocol.allCases
        XCTAssertEqual(allProtocols.count, 5, "There must be exactly 5 ophthalmic protocols")
        
        for proto in allProtocols {
            XCTAssertFalse(proto.title.isEmpty)
            XCTAssertFalse(proto.subtitle.isEmpty)
            XCTAssertFalse(proto.clinicalGuidance.isEmpty)
            XCTAssertFalse(proto.sfSymbolName.isEmpty)
            XCTAssertGreaterThan(proto.defaultDurationSeconds, 0)
            XCTAssertGreaterThan(proto.defaultIntervalMinutes, 0)
        }
        
        // Specific clinical check
        XCTAssertEqual(OphthalmicProtocol.microBreak.defaultDurationSeconds, 20)
        XCTAssertEqual(OphthalmicProtocol.meibomianBlink.defaultDurationSeconds, 60)
        XCTAssertEqual(OphthalmicProtocol.accommodativeFlex.defaultDurationSeconds, 45)
        XCTAssertEqual(OphthalmicProtocol.thermalPalming.defaultDurationSeconds, 90)
        XCTAssertEqual(OphthalmicProtocol.extraocularMotility.defaultDurationSeconds, 30)
    }
    
    // MARK: - 5. Intensity Presets
    func testIntensityPresets() {
        XCTAssertEqual(IntensityPreset.relaxed.microBreakInterval, 30)
        XCTAssertEqual(IntensityPreset.balanced.microBreakInterval, 20)
        XCTAssertEqual(IntensityPreset.deepWork.microBreakInterval, 45)
        
        preferences.selectedPreset = .deepWork
        XCTAssertEqual(preferences.microBreakIntervalMinutes, 45)
        
        preferences.selectedPreset = .relaxed
        XCTAssertEqual(preferences.microBreakIntervalMinutes, 30)
        
        preferences.selectedPreset = .balanced
        XCTAssertEqual(preferences.microBreakIntervalMinutes, 20)
    }
    
    // MARK: - 6. Time Formatting & Progress Fractions
    func testTimeFormatting() {
        appState.secondsRemaining = 125 // 2m 05s
        XCTAssertEqual(appState.formattedTimeRemaining, "02:05")
        
        appState.secondsRemaining = 0
        XCTAssertEqual(appState.formattedTimeRemaining, "00:00")
        
        appState.breakSecondsRemaining = 20
        XCTAssertEqual(appState.formattedBreakTimeRemaining, "00:20")
        
        appState.totalSecondsForCurrentState = 100
        appState.secondsRemaining = 50
        XCTAssertEqual(appState.progressFraction, 0.5, accuracy: 0.001)
        
        appState.breakTotalSeconds = 20
        appState.breakSecondsRemaining = 5
        XCTAssertEqual(appState.breakProgressFraction, 0.75, accuracy: 0.001)
    }
    
    // MARK: - 7. Manual Break Trigger From Menu Bar
    func testManualTriggerOfDifferentProtocols() {
        for proto in OphthalmicProtocol.allCases {
            engine.beginBreak(protocol: proto)
            XCTAssertEqual(appState.timerState, .inBreak)
            XCTAssertEqual(appState.currentProtocol, proto)
            XCTAssertEqual(appState.breakSecondsRemaining, proto.defaultDurationSeconds)
            
            engine.finishBreak()
            XCTAssertEqual(appState.timerState, .working)
        }
    }
}
