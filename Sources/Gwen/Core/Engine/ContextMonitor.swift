import Foundation
import AVFoundation
import CoreGraphics
import Combine

public class ContextMonitor: ObservableObject {
    @Published public var isCameraActive: Bool = false
    @Published public var isMicrophoneActive: Bool = false
    @Published public var idleTimeSeconds: Double = 0.0
    @Published public var isUserIdle: Bool = false

    private var timer: Timer?

    public var isMeetingActive: Bool {
        return isCameraActive || isMicrophoneActive
    }

    public init() {
        startMonitoring()
    }

    public func startMonitoring() {
        // Poll input events & hardware stream status every 2 seconds
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.checkHardwareStreams()
            self?.checkInputIdleTime()
        }
    }

    public func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }

    private func checkHardwareStreams() {
        // Query AVCaptureDevice for active video recording sessions
        let videoDevices = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera],
            mediaType: .video,
            position: .unspecified
        ).devices

        let cameraInUse = videoDevices.contains { device in
            return device.isInUseByAnotherApplication
        }

        DispatchQueue.main.async {
            self.isCameraActive = cameraInUse
        }
    }

    private func checkInputIdleTime() {
        // Query CoreGraphics event source for time since last mouse or keyboard input
        let seconds = CGEventSource.secondsSinceLastEventType(.combinedSessionState, eventType: CGEventType(rawValue: ~0)!)
        
        DispatchQueue.main.async {
            self.idleTimeSeconds = seconds
            self.isUserIdle = seconds >= 180.0 // 3 minutes idle threshold
        }
    }

    deinit {
        stopMonitoring()
    }
}
