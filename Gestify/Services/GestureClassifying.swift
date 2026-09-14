//
//  GestureClassifying.swift
//  Gestify
//
//  Created by Ni Komang Ayu Juliana on 13/09/26.
//

import CoreML
import Vision

protocol GestureClassifying {
    func classify(_ observation: VNHumanHandPoseObservation) -> (label: HandGesture, confidence: Double)?
}
final class GestureCoreMLClassifier: GestureClassifying {

    private let model: MLModel

    init() {
        guard let url = Bundle.main.url(forResource: "MyHandPoseClassifier 1", withExtension: "mlmodelc") else {
            fatalError("GestureClassifier.mlmodelc not found — make sure the .mlmodel file was added to the app target and compiled.")
        }
        do {
            self.model = try MLModel(contentsOf: url)
        } catch {
            fatalError("Failed to load model: \(error)")
        }
    }

    func classify(_ observation: VNHumanHandPoseObservation) -> (label: HandGesture, confidence: Double)? {
        guard let poseMultiArray = try? observation.keypointsMultiArray() else {
            return nil
        }

        guard let input = try? MLDictionaryFeatureProvider(dictionary: ["poses": poseMultiArray]) else {
            return nil
        }

        guard let output = try? model.prediction(from: input) else {
            return nil
        }

        guard let labelValue = output.featureValue(for: "label")?.stringValue else {
            return nil
        }

        let confidence: Double
        if let probFeature = output.featureValue(for: "labelProbabilities"),
           let probDict = probFeature.dictionaryValue as? [String: Double] {
            confidence = probDict[labelValue] ?? 0
        } else {
            confidence = 1.0 // fallback if the model doesn't expose probabilities
        }

        let gesture = HandGesture(rawValue: labelValue) ?? .none
        return (gesture, confidence)
    }
}
