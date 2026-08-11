import Foundation
import SwiftUI
import Combine

public enum TimerState: String, Codable {
    case working = "Working"
    case preBreakWarning = "Break Approaching"
    case inBreak = "In Break"
    case pausedIdle = "AFK Detected"
    case pausedMeeting = "In Meeting"
    case manuallyPaused = "Paused"

    public var statusBadgeColor: Color {
        switch self {
        case .working: return Color.emeraldGreen
        case .preBreakWarning: return Color.amberGold
        case .inBreak: return Color.cyan
        case .pausedIdle: return Color.gray
        case .pausedMeeting: return Color.deepLavender
        case .manuallyPaused: return Color.gray
        }
    }
}

public class AppState: ObservableObject {
    @Published public var timerState: TimerState = .working
    @Published public var currentProtocol: OphthalmicProtocol = .microBreak
    
    @Published public var isPaused: Bool = false
    @Published public var sessionStartTime: Date = Date()
    @Published public var totalWorkSecondsToday: Int = 0
    
    /// Countdown remaining for active state in seconds.
    @Published public var secondsRemaining: Int = 1200 // 20 minutes default
    @Published public var totalSecondsForCurrentState: Int = 1200
    
    /// Seconds remaining for active break exercise.
    @Published public var breakSecondsRemaining: Int = 20
    @Published public var breakTotalSeconds: Int = 20

    // Session Statistics
    @Published public var breaksCompletedToday: Int = 0
    @Published public var totalRelaxationSecondsToday: Int = 0
    @Published public var estimatedTearFilmScore: Int = 88 // Percentage

    // Real-time Vision Engine State (M4 Neural Engine)
    @Published public var isCameraActive: Bool = false
    @Published public var blinksPerMinute: Int = 16
    @Published public var postureAngleDegrees: Double = 15.0 // Ideal 15-20 deg downward
    @Published public var isPostureOptimal: Bool = true
    @Published public var isBlinkRateDeficient: Bool = false

    public var progressFraction: Double {
        guard totalSecondsForCurrentState > 0 else { return 0 }
        let elapsed = totalSecondsForCurrentState - secondsRemaining
        return min(max(Double(elapsed) / Double(totalSecondsForCurrentState), 0.0), 1.0)
    }

    public var breakProgressFraction: Double {
        guard breakTotalSeconds > 0 else { return 0 }
        let elapsed = breakTotalSeconds - breakSecondsRemaining
        return min(max(Double(elapsed) / Double(breakTotalSeconds), 0.0), 1.0)
    }

    public var formattedTimeRemaining: String {
        let mins = secondsRemaining / 60
        let secs = secondsRemaining % 60
        return String(format: "%02d:%02d", mins, secs)
    }

    public var formattedBreakTimeRemaining: String {
        let mins = breakSecondsRemaining / 60
        let secs = breakSecondsRemaining % 60
        return String(format: "%02d:%02d", mins, secs)
    }
    
    public var formattedSessionDuration: String {
        let elapsed = Int(Date().timeIntervalSince(sessionStartTime))
        let hours = elapsed / 3600
        let minutes = (elapsed % 3600) / 60
        return "\(hours)h \(minutes)m"
    }

    public init() {}
}
