import Foundation
import Vision
import AVFoundation
import Combine

public class VisionAnalyticsEngine: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    @Published public var isSessionActive: Bool = false
    @Published public var blinksPerMinute: Int = 18
    @Published public var postureAngleDegrees: Double = 16.0
    @Published public var isPostureOptimal: Bool = true
    @Published public var isBlinkDeficient: Bool = false

    private var captureSession: AVCaptureSession?
    private var sequenceHandler = VNSequenceRequestHandler()
    private var blinkHistory: [Date] = []

    public override init() {
        super.init()
    }

    public func startSession() {
        #if targetEnvironment(simulator)
        return
        #else
        guard captureSession == nil else { return }

        let session = AVCaptureSession()
        session.sessionPreset = .low

        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let input = try? AVCaptureDeviceInput(device: device) else {
            return
        }

        if session.canAddInput(input) {
            session.canAddInput(input)
            session.addInput(input)
        }

        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "gwen.vision.queue"))
        
        if session.canAddOutput(output) {
            session.addOutput(output)
        }

        self.captureSession = session
        DispatchQueue.global(qos: .userInitiated).async {
            session.startRunning()
            DispatchQueue.main.async {
                self.isSessionActive = true
            }
        }
        #endif
    }

    public func stopSession() {
        captureSession?.stopRunning()
        captureSession = nil
        DispatchQueue.main.async {
            self.isSessionActive = false
        }
    }

    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let request = VNDetectFaceLandmarksRequest { [weak self] request, error in
            guard let results = request.results as? [VNFaceObservation], let face = results.first else { return }
            self?.processFaceObservation(face)
        }

        try? sequenceHandler.perform([request], on: pixelBuffer, orientation: .leftMirrored)
    }

    private func processFaceObservation(_ face: VNFaceObservation) {
        // Calculate posture head tilt (pitch/roll)
        let roll = face.roll?.doubleValue ?? 0.0

        let postureAngle = 15.0 - abs(roll * 180.0 / .pi)

        // Eyelid apposition check for blink detection
        if let landmarks = face.landmarks, let leftEye = landmarks.leftEye, let rightEye = landmarks.rightEye {
            let leftPoints = leftEye.normalizedPoints
            let rightPoints = rightEye.normalizedPoints

            if leftPoints.count >= 6 && rightPoints.count >= 6 {
                let leftEyeHeight = abs(leftPoints[1].y - leftPoints[5].y)
                let rightEyeHeight = abs(rightPoints[1].y - rightPoints[5].y)

                if leftEyeHeight < 0.015 && rightEyeHeight < 0.015 {
                    recordBlink()
                }
            }
        }

        DispatchQueue.main.async {
            self.postureAngleDegrees = max(5.0, min(30.0, postureAngle))
            self.isPostureOptimal = postureAngle >= 12.0 && postureAngle <= 22.0
        }
    }

    private func recordBlink() {
        let now = Date()
        blinkHistory.append(now)
        
        // Retain blinks from last 60 seconds
        blinkHistory = blinkHistory.filter { now.timeIntervalSince($0) <= 60.0 }
        
        let count = blinkHistory.count
        DispatchQueue.main.async {
            self.blinksPerMinute = count
            self.isBlinkDeficient = count < 10
        }
    }
}
