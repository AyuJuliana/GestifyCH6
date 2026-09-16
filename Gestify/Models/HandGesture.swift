//
//  HandGesture.swift
//  Gestify
//
//  Created by Ni Komang Ayu Juliana on 13/09/26.
//

import Foundation
enum HandGesture: String, CaseIterable {
    case play       // open palm, 5 fingers
    case pause      // fist, 0 fingers
    case next       // rock fingers
    case previous   // call 
    case none

    var displayName: String {
        switch self {
        case .play: return "Play"
        case .pause: return "Pause"
        case .next: return "Next"
        case .previous: return "Previous"
        case .none: return "-"
        }
    }

    var emoji: String {
        switch self {
        case .play: return "✋"
        case .pause: return "✊"
        case .next: return "🤘"
        case .previous: return "🤙"
        case .none: return ""
        }
    }
}
