//
//  GestureViewModel.swift
//  Gestify
//
//  Created by Ni Komang Ayu Juliana on 13/09/26.
//

import Foundation
import Combine
import CoreVideo
import AVFoundation

enum PlaybackState {
    case playing
    case paused
}

@MainActor
final class GestureViewModel: NSObject, ObservableObject, CameraManagerDelegate {

    nonisolated func cameraManager(_ manager: CameraManaging, didCapture pixelBuffer: CVPixelBuffer) {
        Task { @MainActor in
            let result = self.detector.processFrame(pixelBuffer, cameraPosition: self.cameraPosition)
            self.currentGesture = result.raw

            guard let confirmed = result.confirmed else { return }
            self.lastConfirmedGesture = confirmed
            self.execute(confirmed)
        }
    }

    nonisolated func cameraManagerDidFailPermission(_ manager: any CameraManaging) {
        Task { @MainActor in
            cameraPermissionDenied = true
        }
    }

    @Published private(set) var currentGesture: HandGesture = .none
    @Published private(set) var lastConfirmedGesture: HandGesture = .none
    @Published var cameraPermissionDenied: Bool = false
    @Published private(set) var playbackState: PlaybackState = .paused
    @Published private(set) var cameraPosition: AVCaptureDevice.Position

    let camera: CameraManaging
    let music: MusicControlling
    private let detector: GestureDetecting

    init(camera: CameraManaging, music: MusicControlling, detector: GestureDetecting) {
        self.camera = camera
        self.music = music
        self.detector = detector
        self.cameraPosition = camera.position
        super.init()
        camera.delegate = self
    }

    func start() { camera.start() }
    func applySensitivity(_ value: Double) { detector.updateSensitivity(value) }
    func requestMusicAuthorization() async { await music.requestAuthorization() }

    func switchCamera() {
        camera.switchCamera()
        cameraPosition = camera.position
    }

    private func execute(_ gesture: HandGesture) {
        switch gesture {
        case .play:
            guard playbackState != .playing else { return }
            music.play()
            playbackState = .playing

        case .pause:
            guard playbackState != .paused else { return }
            music.pause()
            playbackState = .paused

        case .next:
            music.next()
            playbackState = .playing

        case .previous:
            music.previous()
            playbackState = .playing

        case .none:
            break
        }
    }
}
