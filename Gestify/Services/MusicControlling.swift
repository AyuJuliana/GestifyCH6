//
//  MusicControlling.swift
//  Gestify
//
//  Created by Ni Komang Ayu Juliana on 13/09/26.
//

import MusicKit
import Foundation
import Combine

protocol MusicControlling: AnyObject {
    var isAuthorized: Bool { get }
    var nowPlayingTitle: String { get }
    var nowPlayingArtist: String { get }

    func requestAuthorization() async
    func play()
    func pause()
    func next()
    func previous()
}

@MainActor
final class MusicController: ObservableObject, MusicControlling {
    @Published var isAuthorized = false
    @Published var nowPlayingTitle: String = "Nothing playing"
    @Published var nowPlayingArtist: String = ""

    private let player = SystemMusicPlayer.shared
    private var refreshTimer: Timer?

    init() {
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.refreshNowPlaying()
            }
        }
    }

    deinit {
        refreshTimer?.invalidate()
    }

    func requestAuthorization() async {
        let status = await MusicAuthorization.request()
        isAuthorized = (status == .authorized)
    }

    func play() {
        Task {
            do {
                try await player.play()
                refreshNowPlaying()
            } catch {
                print("Play error: \(error)")
            }
        }
    }

    func pause() {
        player.pause()
    }

    func next() {
        Task {
            do {
                try await player.skipToNextEntry()
//                refreshNowPlaying()
            } catch {
                print("Next error: \(error)")
            }
        }
    }

    func previous() {
        Task {
            do {
                try await player.skipToPreviousEntry()
                refreshNowPlaying()
            } catch {
                print("Previous error: \(error)")
            }
        }
    }

    private func refreshNowPlaying() {
        if let item = player.queue.currentEntry {
            nowPlayingTitle = item.title
            nowPlayingArtist = item.subtitle ?? ""
        }
    }
}
