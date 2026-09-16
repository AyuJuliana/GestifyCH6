//
//  GestureTips.swift
//  Gestify
//
//  Created by Ni Komang Ayu Juliana on 13/09/26.
//

import TipKit

struct OnboardingParameters {
    @Parameter
    static var hasCompletedOnboarding: Bool = false
}

struct PlayGestureTip: Tip {
    var title: Text { Text("Play") }
    var message: Text? { Text("Show an open palm (✋) to the camera to play the current song.") }
    var image: Image? { Image(systemName: "hand.raised.fill") }
}

struct PauseGestureTip: Tip {
    var title: Text { Text("Pause") }
    var message: Text? { Text("Make a fist (✊) to pause the song that's playing.") }
    var image: Image? { Image(systemName: "hand.raised.slash.fill") }
}

struct NextGestureTip: Tip {
    var title: Text { Text("Next song") }
    var message: Text? { Text("Raise your thumb, index, and pinky finger(🤘) to skip to the next song.") }
    var image: Image? { Image(systemName: "forward.end.fill") }
}

struct PreviousGestureTip: Tip {
    var title: Text { Text("Previous song") }
    var message: Text? { Text("Raise your thumb and pinky finger only (🤙) to go back to the previous song.")}
    var image: Image? { Image(systemName: "backward.end.fill") }
}

struct AdvancedSensitivityTip: Tip {
    var title: Text { Text("Gesture sensitivity") }
    var message: Text? { Text("If gestures are being misread often, lower the sensitivity in Settings.") }
    var image: Image? { Image(systemName: "slider.horizontal.3") }
}

struct NowPlayingTip: Tip {
    var title: Text { Text("Now playing") }
    var message: Text? { Text("The title and artist of the current track show up here in real time.") }
    var image: Image? { Image(systemName: "music.note") }

    var rules: [Rule] {
        #Rule(OnboardingParameters.$hasCompletedOnboarding) { $0 == true }
    }
}

struct CameraFlipTip: Tip {
    var title: Text { Text("Switch camera") }
    var message: Text? { Text("Tap this icon to switch the camera between the front camera and back camera while scanning your hand gesture.") }
    var image: Image? { Image(systemName: "arrow.triangle.2.circlepath.camera.fill") }

    var rules: [Rule] {
        #Rule(OnboardingParameters.$hasCompletedOnboarding) { $0 == true }
    }
}

struct GesturePredictionTip: Tip {
    var title: Text { Text("Gesture detection result") }
    var message: Text? { Text("This shows the gesture currently being read, and updates automatically each time the camera detects a new one.") }
    var image: Image? { Image(systemName: "hand.raised.fill") }

    var rules: [Rule] {
        #Rule(OnboardingParameters.$hasCompletedOnboarding) { $0 == true }
    }
}

