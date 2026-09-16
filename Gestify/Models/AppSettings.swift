//
//  AppSettings.swift
//  Gestify
//
//  Created by Ni Komang Ayu Juliana on 13/09/26.
//

import Foundation
import SwiftUI
import Combine


final class AppSettings: ObservableObject {
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false 
    @AppStorage("hasSeenTutorial") var hasSeenTutorial: Bool = false
    @AppStorage("gestureSensitivity") var gestureSensitivity: Double = 0.7 // 0.5 (loose) - 0.95 (strict)
}
