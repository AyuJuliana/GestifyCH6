//
//  GestureFeedbackCard.swift
//  Gestify
//
//  Created by Ni Komang Ayu Juliana on 13/09/26.
//

import SwiftUI

struct GestureFeedbackCard: View {
    let currentGesture: HandGesture
    let lastConfirmedGesture: HandGesture

    @State private var pulse = false
    private var isActive: Bool { currentGesture != .none }

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Theme.accentGradient.opacity(isActive ? 0.9 : 0.25))
                    .frame(width: 64, height: 64)
                    .scaleEffect(pulse ? 1.15 : 1.0)
                    .shadow(color: .purple.opacity(isActive ? 0.5 : 0), radius: 12)
                Text(currentGesture.emoji).font(.system(size: 30))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(isActive ? currentGesture.displayName : "Waiting for gesture…")
                    .font(.headline)
                    .foregroundStyle(.white)

                if lastConfirmedGesture != .none {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill").foregroundStyle(.green).font(.caption)
                        Text("Last: \(lastConfirmedGesture.displayName)")
                            .font(.caption).foregroundStyle(.white.opacity(0.6))
                    }
                } else {
                    Text("Show a gesture to the camera")
                        .font(.caption).foregroundStyle(.white.opacity(0.5))
                }
            }
            Spacer()
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: Theme.cornerRadius))
        .overlay(RoundedRectangle(cornerRadius: Theme.cornerRadius).stroke(Theme.cardStroke, lineWidth: 1))
        .onChange(of: lastConfirmedGesture) { _, _ in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.4)) { pulse = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                withAnimation { pulse = false }
            }
        }
    }
}
