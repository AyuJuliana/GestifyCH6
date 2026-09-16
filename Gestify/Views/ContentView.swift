//
//  ContentView.swift
//  Gestify
//
//  Created by Ni Komang Ayu Juliana on 13/09/26.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var settings: AppSettings
    @StateObject private var viewModel = GestureViewModel(
        camera: CameraManager(), music: MusicController(), detector: GestureDetector()
    )
    @State private var showTutorial = false

    private var isDetecting: Bool { viewModel.currentGesture != .none }

    var body: some View {
        ZStack {
            Theme.backgroundGradient.ignoresSafeArea()

            VStack(spacing: 18) {
                topBar
                NowPlayingCard(title: viewModel.music.nowPlayingTitle, artist: viewModel.music.nowPlayingArtist)
                    .padding(.horizontal)
                cameraFrame
                    .padding(.horizontal)
                GestureFeedbackCard(currentGesture: viewModel.currentGesture, lastConfirmedGesture: viewModel.lastConfirmedGesture)
                    .padding(.horizontal)
                Spacer()
            }
            .padding(.top, 8)
        }
        .sheet(isPresented: $showTutorial) { TutorialView() }
        .alert("Izin Kamera Dibutuhkan", isPresented: $viewModel.cameraPermissionDenied) {
            Button("Buka Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) { UIApplication.shared.open(url) }
            }
            Button("Batal", role: .cancel) { }
        } message: {
            Text("Gestify butuh akses kamera untuk mendeteksi gesture tanganmu.")
        }
        .task {
            viewModel.applySensitivity(settings.gestureSensitivity)
            await viewModel.requestMusicAuthorization()
            viewModel.start()
            UIApplication.shared.isIdleTimerDisabled = true
            if !settings.hasSeenTutorial { showTutorial = true }
        }
        .onDisappear { UIApplication.shared.isIdleTimerDisabled = false }
    }

    private var cameraFrame: some View {
        CameraPreviewView(session: viewModel.camera.session)
            .frame(height: 380)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
            .overlay(alignment: .topTrailing) {
                Button {
                    viewModel.switchCamera()
                } label: {
                    Image(systemName: "arrow.triangle.2.circlepath.camera.fill")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(10)
                        .background(.ultraThinMaterial, in: Circle())
                }
                .padding(12)
            }
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cornerRadius)
                    .strokeBorder(
                        isDetecting ? AnyShapeStyle(Theme.accentGradient) : AnyShapeStyle(Color.white.opacity(0.12)),
                        lineWidth: isDetecting ? 3 : 1
                    )
            )
            .shadow(color: isDetecting ? .purple.opacity(0.35) : .clear, radius: 20)
            .animation(.easeInOut(duration: 0.25), value: isDetecting)
    }

    private var topBar: some View {
        HStack {
            Text("Gestify").font(.title2.weight(.bold)).foregroundStyle(.white)
            Spacer()
            Button { showTutorial = true } label: {
                Image(systemName: "questionmark.circle.fill")
                    .font(.title2).foregroundStyle(.white.opacity(0.85))
                    .padding(8).background(.ultraThinMaterial, in: Circle())
            }
        }
        .padding(.horizontal)
    }
}


#Preview {
    ContentView()
        .environmentObject(AppSettings())
}
