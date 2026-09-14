//
//  GestureDetecting.swift
//  Gestify
//
//  Created by Ni Komang Ayu Juliana on 13/09/26.
//

import Vision
import CoreImage
import UIKit

struct GestureDetectionResult {
    let raw: HandGesture
    let confirmed: HandGesture?
}

protocol GestureDetecting {
    func processFrame(_ pixelBuffer: CVPixelBuffer) -> GestureDetectionResult
    func updateSensitivity(_ value: Double)
}

final class GestureDetector: GestureDetecting {
    
    private var confidenceThreshold: Double
    private let requiredConsecutiveFrames: Int
    private let cooldownInterval: TimeInterval

    private var recentGestures: [HandGesture] = []
    private var lastActionTime: Date = .distantPast

    private let handPoseRequest = VNDetectHumanHandPoseRequest()
    private let classifier: GestureClassifying

    init(
        classifier: GestureClassifying = GestureCoreMLClassifier(),
        confidenceThreshold: Double = 0.7,
        requiredConsecutiveFrames: Int = 3,
        cooldownInterval: TimeInterval = 1.0
    ) {
        self.classifier = classifier
        self.confidenceThreshold = confidenceThreshold
        self.requiredConsecutiveFrames = requiredConsecutiveFrames
        self.cooldownInterval = cooldownInterval
        handPoseRequest.maximumHandCount = 1
    }

    func updateSensitivity(_ value: Double) {
        confidenceThreshold = value
    }

    func processFrame(_ pixelBuffer: CVPixelBuffer) -> GestureDetectionResult {
        guard let observation = detectHandPose(in: pixelBuffer) else {
            recentGestures.removeAll()
            return GestureDetectionResult(raw: .none, confirmed: nil)
        }

        guard let classification = classifier.classify(observation) else {
            recentGestures.removeAll()
            return GestureDetectionResult(raw: .none, confirmed: nil)
        }

        let raw = classification.confidence >= confidenceThreshold ? classification.label : .none

        guard isStable(raw), hasCooldownElapsed() else {
            return GestureDetectionResult(raw: raw, confirmed: nil)
        }

        lastActionTime = Date()
        return GestureDetectionResult(raw: raw, confirmed: raw)
    }

    private func detectHandPose(in pixelBuffer: CVPixelBuffer) -> VNHumanHandPoseObservation? {
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: currentExifOrientation(), options: [:])
        do {
            try handler.perform([handPoseRequest])
            return handPoseRequest.results?.first
        } catch {
            return nil
        }
    }
    private func currentExifOrientation() -> CGImagePropertyOrientation {
        switch UIDevice.current.orientation {
        case .landscapeLeft:
            return .upMirrored
        case .landscapeRight:
            return .downMirrored
        case .portraitUpsideDown:
            return .rightMirrored
        case .portrait, .faceUp, .faceDown, .unknown:
            fallthrough
        @unknown default:
            return .leftMirrored
        }
    }

    private func isStable(_ raw: HandGesture) -> Bool {
        recentGestures.append(raw)
        if recentGestures.count > requiredConsecutiveFrames {
            recentGestures.removeFirst()
        }
        return recentGestures.count == requiredConsecutiveFrames &&
               recentGestures.allSatisfy { $0 == raw } &&
               raw != .none
    }

    private func hasCooldownElapsed() -> Bool {
        Date().timeIntervalSince(lastActionTime) > cooldownInterval
    }
}
