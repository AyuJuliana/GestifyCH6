//
//  AppSettings.swift
//  Gestify
//
//  Created by Ni Komang Ayu Juliana on 13/09/26.
//

import Foundation
import SwiftUI
import Combine

enum DominantHand: String, CaseIterable, Identifiable {
    case right, left
    var id: String { rawValue }
    var label: String { self == .right ? "Right" : "Left" }
}

final class AppSettings: ObservableObject {
    @AppStorage("hasSeenTutorial") var hasSeenTutorial: Bool = false
    @AppStorage("dominantHand") var dominantHandRaw: String = DominantHand.right.rawValue
    @AppStorage("soundFeedbackEnabled") var soundFeedbackEnabled: Bool = true
    @AppStorage("gestureSensitivity") var gestureSensitivity: Double = 0.7 // 0.5 (loose) - 0.95 (strict)

    var dominantHand: DominantHand {
        get { DominantHand(rawValue: dominantHandRaw) ?? .right }
        set { dominantHandRaw = newValue.rawValue }
    }
}
