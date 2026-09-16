//
//  GestureClassifying.swift
//  Gestify
//
//  Created by Ni Komang Ayu Juliana on 13/09/26.
//

import CoreML
import CoreImage
import CoreVideo
import Vision
import ImageIO

protocol GestureClassifying {
    func classify(_ pixelBuffer: CVPixelBuffer, orientation: CGImagePropertyOrientation) -> (label: HandGesture, confidence: Double)?
}

final class GestureCoreMLClassifier: GestureClassifying {

    private let model: MLModel
    private let ciContext = CIContext()
    private let inputSize = 360

    // searching the hand request
    private let handLocatorRequest: VNDetectHumanHandPoseRequest = {
        let request = VNDetectHumanHandPoseRequest()
        request.maximumHandCount = 1
        return request
    }()

    
    //read and load the models
    init() {
        guard let url = Bundle.main.url(forResource: "NewImageClassifier", withExtension: "mlmodelc") else {
            fatalError("ImageGestureClassifier.mlmodelc not found.")
        }
        do {
            self.model = try MLModel(contentsOf: url)
        } catch {
            fatalError("Failed to load model: \(error)")
        }
    }

    
    func classify(_ pixelBuffer: CVPixelBuffer, orientation: CGImagePropertyOrientation) -> (label: HandGesture, confidence: Double)? {
        // check the hand
        guard let handBox = detectHandBoundingBox(pixelBuffer, orientation: orientation) else {
            return nil   //If there is no hand, it stops immediately and doesn't reach the classifier
        }

        // crop the hand,and then go to the model classifier
        guard let resized = croppedAndResized(pixelBuffer, orientation: orientation, box: handBox, size: inputSize) else {
            return nil
        }

        guard let input = try? MLDictionaryFeatureProvider(dictionary: ["image": resized]),
              let output = try? model.prediction(from: input),
              let label = output.featureValue(for: "target")?.stringValue else {
            return nil
        }

        var confidence = 1.0
        if let probFeature = output.featureValue(for: "targetProbability"),
           let probDict = probFeature.dictionaryValue as? [String: Double] {
            confidence = probDict[label] ?? 0
        }

        return (HandGesture(rawValue: label) ?? .none, confidence)
    }
    
    //Hand bounding box to check for the presence of a hand, if there is no hand at all in the frame, the face and background are automatically ignored here.
    private func detectHandBoundingBox(_ pixelBuffer: CVPixelBuffer, orientation: CGImagePropertyOrientation) -> CGRect? {
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: orientation, options: [:])
        try? handler.perform([handLocatorRequest])

        guard let observation = handLocatorRequest.results?.first,
              let points = try? observation.recognizedPoints(.all) else { return nil }

        let confidentPoints = points.values.filter { $0.confidence > 0.3 }
        guard !confidentPoints.isEmpty else { return nil }

        let xs = confidentPoints.map { $0.location.x }
        let ys = confidentPoints.map { $0.location.y }
        guard let minX = xs.min(), let maxX = xs.max(),
              let minY = ys.min(), let maxY = ys.max() else { return nil }

        let padding = 0.35
        let width = maxX - minX
        let height = maxY - minY
        return CGRect(
            x: max(0, minX - width * padding),
            y: max(0, minY - height * padding),
            width: min(1, width * (1 + padding * 2)),
            height: min(1, height * (1 + padding * 2))
        )
    }

    private func croppedAndResized(_ pixelBuffer: CVPixelBuffer, orientation: CGImagePropertyOrientation, box: CGRect, size: Int) -> CVPixelBuffer? {
        var outputBuffer: CVPixelBuffer?
        let attrs: [CFString: Any] = [
            kCVPixelBufferCGImageCompatibilityKey: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey: true
        ]
        CVPixelBufferCreate(kCFAllocatorDefault, size, size, kCVPixelFormatType_32BGRA, attrs as CFDictionary, &outputBuffer)
        guard let outputBuffer else { return nil }

        let oriented = CIImage(cvPixelBuffer: pixelBuffer).oriented(orientation)

        // box from Vision the vision
        let pixelRect = CGRect(
            x: box.minX * oriented.extent.width,
            y: box.minY * oriented.extent.height,
            width: box.width * oriented.extent.width,
            height: box.height * oriented.extent.height
        )

        let cropped = oriented.cropped(to: pixelRect)
        let scale = CGFloat(size) / max(pixelRect.width, pixelRect.height)
        let scaled = cropped
            .transformed(by: CGAffineTransform(translationX: -pixelRect.minX, y: -pixelRect.minY))
            .transformed(by: CGAffineTransform(scaleX: scale, y: scale))

        ciContext.render(scaled, to: outputBuffer)
        return outputBuffer
    }
}
