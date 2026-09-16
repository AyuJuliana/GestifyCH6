//
//  GestureDetecting.swift
//  Gestify
//
//  Created by Ni Komang Ayu Juliana on 13/09/26.
//

import CoreImage
import ImageIO
import UIKit
import AVFoundation

struct GestureDetectionResult {
    let raw: HandGesture
    let confirmed: HandGesture?
}

protocol GestureDetecting {
    func processFrame(_ pixelBuffer: CVPixelBuffer, cameraPosition: AVCaptureDevice.Position) -> GestureDetectionResult
    func updateSensitivity(_ value: Double)
}

final class GestureDetector: GestureDetecting {

    private var confidenceThreshold: Double
    private let requiredConsecutiveFrames: Int
    private let cooldownInterval: TimeInterval

    private var recentGestures: [HandGesture] = []
    private var lastActionTime: Date = .distantPast

    private let classifier: GestureClassifying

    init(
        classifier: GestureClassifying = GestureCoreMLClassifier(),
        confidenceThreshold: Double = 0.85,
        requiredConsecutiveFrames: Int = 10,
        cooldownInterval: TimeInterval = 1.5
    ) {
        self.classifier = classifier
        self.confidenceThreshold = confidenceThreshold
        self.requiredConsecutiveFrames = requiredConsecutiveFrames
        self.cooldownInterval = cooldownInterval
    }

    func updateSensitivity(_ value: Double) {
        confidenceThreshold = value
    }

    func processFrame(_ pixelBuffer: CVPixelBuffer, cameraPosition: AVCaptureDevice.Position) -> GestureDetectionResult {
        guard let classification = classifier.classify(pixelBuffer, orientation: currentExifOrientation(for: cameraPosition)) else {
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

    private func currentExifOrientation(for position: AVCaptureDevice.Position) -> CGImagePropertyOrientation {
        let isMirrored = position == .front
        switch UIDevice.current.orientation {
        case .landscapeLeft: return isMirrored ? .upMirrored : .down
        case .landscapeRight: return isMirrored ? .downMirrored : .up
        case .portraitUpsideDown: return isMirrored ? .rightMirrored : .left
        case .portrait, .faceUp, .faceDown, .unknown: fallthrough
        @unknown default: return isMirrored ? .leftMirrored : .right
        }
    }

    private func isStable(_ raw: HandGesture) -> Bool {
        recentGestures.append(raw)
        if recentGestures.count > requiredConsecutiveFrames { recentGestures.removeFirst() }
        return recentGestures.count == requiredConsecutiveFrames &&
               recentGestures.allSatisfy { $0 == raw } && raw != .none
    }

    private func hasCooldownElapsed() -> Bool {
        Date().timeIntervalSince(lastActionTime) > cooldownInterval
    }
}
