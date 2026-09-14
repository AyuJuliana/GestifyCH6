//
//  GestureTips.swift
//  Gestify
//
//  Created by Ni Komang Ayu Juliana on 13/09/26.
//

import TipKit

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
    var message: Text? { Text("Raise two fingers, index and middle (✌️), to skip to the next song.") }
    var image: Image? { Image(systemName: "hand.point.up.left.fill") }
}

struct PreviousGestureTip: Tip {
    var title: Text { Text("Previous song") }
    var message: Text? { Text("Raise one finger, index only (☝️), to go back to the previous song.") }
    var image: Image? { Image(systemName: "hand.point.up.fill") }
}

struct AdvancedSensitivityTip: Tip {
    var title: Text { Text("Gesture sensitivity") }
    var message: Text? { Text("If gestures are being misread often, lower the sensitivity in Settings.") }
    var image: Image? { Image(systemName: "slider.horizontal.3") }
}
