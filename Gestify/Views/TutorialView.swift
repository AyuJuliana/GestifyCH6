//
//  SwiftUIView.swift
//  Gestify
//
//  Created by Ni Komang Ayu Juliana on 13/09/26.
//

import SwiftUI
import TipKit

struct TutorialView: View {
    @EnvironmentObject private var settings: AppSettings
    @Environment(\.dismiss) private var dismiss

    @State private var selectedHand: DominantHand = .right
    @State private var soundFeedback: Bool = true
    @State private var sensitivity: Double = 0.7
    @State private var showAdvancedTip: Bool = false

    private let advancedTip = AdvancedSensitivityTip()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    header
                    card { handSelectionSection }
                    card { soundToggleSection }
                    card { sensitivitySliderSection }

                    Text("Available gestures")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)

                    TipView(PlayGestureTip()).tipViewStyle(GestureTipStyle())
                    TipView(PauseGestureTip()).tipViewStyle(GestureTipStyle())
                    TipView(NextGestureTip()).tipViewStyle(GestureTipStyle())
                    TipView(PreviousGestureTip()).tipViewStyle(GestureTipStyle())

                    doneButton
                }
                .padding(20)
            }
            .scrollContentBackground(.hidden)
            .background(Theme.backgroundGradient.ignoresSafeArea())
            .navigationTitle("Tutorial")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") { saveAndClose() }.foregroundStyle(.white)
                }
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            selectedHand = settings.dominantHand
            soundFeedback = settings.soundFeedbackEnabled
            sensitivity = settings.gestureSensitivity
        }
        .task { try? Tips.configure() }
    }

    private func card<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        content()
            .padding(16)
            .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: Theme.cornerRadius))
            .overlay(RoundedRectangle(cornerRadius: Theme.cornerRadius).stroke(Theme.cardStroke, lineWidth: 1))
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("How Gestify works")
                .font(.title2.weight(.bold)).foregroundStyle(.white)
            Text("Review the gestures and adjust your preferences anytime.")
                .font(.subheadline).foregroundStyle(.white.opacity(0.6))
        }
    }

    private var handSelectionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Dominant hand").font(.subheadline.weight(.medium)).foregroundStyle(.white)
            Picker("Dominant hand", selection: $selectedHand) {
                ForEach(DominantHand.allCases) { hand in Text(hand.label).tag(hand) }
            }
            .pickerStyle(.segmented)

            Text(selectedHand == .left
                 ? "Position your left hand in front of the camera. Some gestures (☝️, ✌️) can feel slightly mirrored, that's expected."
                 : "Position your right hand in front of the camera for the best detection results.")
                .font(.caption).foregroundStyle(.white.opacity(0.55))
        }
    }

    private var soundToggleSection: some View {
        Toggle(isOn: $soundFeedback) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Sound feedback").font(.subheadline.weight(.medium)).foregroundStyle(.white)
                Text("A short click plays each time a gesture is recognized.")
                    .font(.caption).foregroundStyle(.white.opacity(0.55))
            }
        }
        .tint(.purple)
    }

    private var sensitivitySliderSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Gesture sensitivity").font(.subheadline.weight(.medium)).foregroundStyle(.white)
                Spacer()
                Text("\(Int(sensitivity * 100))%").font(.caption).foregroundStyle(.white.opacity(0.6))
            }
            Slider(value: $sensitivity, in: 0.5...0.95, step: 0.05)
                .tint(.purple)
                .onChange(of: sensitivity) { _, newValue in
                    if newValue < 0.6 { showAdvancedTip = true }
                }
            if showAdvancedTip {
                TipView(advancedTip).tipViewStyle(GestureTipStyle())
            }
        }
    }

    private var doneButton: some View {
        Button { saveAndClose() } label: {
            Text("Done").frame(maxWidth: .infinity).padding(.vertical, 14).fontWeight(.semibold)
        }
        .background(Theme.accentGradient, in: RoundedRectangle(cornerRadius: 16))
        .foregroundStyle(.white)
    }

    private func saveAndClose() {
        settings.dominantHand = selectedHand
        settings.soundFeedbackEnabled = soundFeedback
        settings.gestureSensitivity = sensitivity
        settings.hasSeenTutorial = true
        dismiss()
    }
}

#Preview {
    TutorialView()
        .environmentObject(AppSettings())
}
