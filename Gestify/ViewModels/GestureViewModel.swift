//
//  GestureViewModel.swift
//  Gestify
//
//  Created by Ni Komang Ayu Juliana on 13/09/26.
//

import Foundation
import Combine
import CoreVideo

@MainActor
final class GestureViewModel: NSObject, ObservableObject {
    @Published private(set) var currentGesture: HandGesture = .none        // live, updates every frame
    @Published private(set) var lastConfirmedGesture: HandGesture = .none  // the one that actually fired an action
    @Published var cameraPermissionDenied: Bool = false

    let camera: CameraManaging
    let music: MusicControlling
    private let detector: GestureDetecting

    init(
        camera: CameraManaging,
        music: MusicControlling,
        detector: GestureDetecting
    ) {
        self.camera = camera
        self.music = music
        self.detector = detector
        super.init()
        camera.delegate = self
    }

    func start() {
        camera.start()
    }

    func applySensitivity(_ value: Double) {
        detector.updateSensitivity(value)
    }

    func requestMusicAuthorization() async {
        await music.requestAuthorization()
    }

    private func execute(_ gesture: HandGesture) {
        switch gesture {
        case .play: music.play()
        case .pause: music.pause()
        case .next: music.next()
        case .previous: music.previous()
        case .none: break
        }
    }
}

// MARK: - CameraManagerDelegate
extension GestureViewModel: CameraManagerDelegate {
    nonisolated func cameraManager(_ manager: CameraManaging, didCapture pixelBuffer: CVPixelBuffer) {
        Task { @MainActor in
            let result = self.detector.processFrame(pixelBuffer)
            self.currentGesture = result.raw

            guard let confirmed = result.confirmed else { return }
            self.lastConfirmedGesture = confirmed
            self.execute(confirmed)
        }
    }

    nonisolated func cameraManagerDidFailPermission(_ manager: CameraManaging) {
        Task { @MainActor in
            self.cameraPermissionDenied = true
        }
    }
}
