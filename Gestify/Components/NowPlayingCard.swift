//
//  NowPlayingCard.swift
//  Gestify
//
//  Created by Ni Komang Ayu Juliana on 13/09/26.
//

import SwiftUI

struct NowPlayingCard: View {
    let title: String
    let artist: String

    @State private var animateBars = false

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Theme.accentGradient)
                    .frame(width: 52, height: 52)

                HStack(spacing: 3) {
                    ForEach(0..<3, id: \.self) { i in
                        Capsule()
                            .fill(.white.opacity(0.9))
                            .frame(width: 3, height: animateBars ? CGFloat.random(in: 8...20) : 10)
                            .animation(
                                .easeInOut(duration: 0.5).repeatForever().delay(Double(i) * 0.15),
                                value: animateBars
                            )
                    }
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                Text(artist)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
                    .lineLimit(1)
            }
            Spacer()
        }
        .padding(12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: Theme.cornerRadius))
        .overlay(RoundedRectangle(cornerRadius: Theme.cornerRadius).stroke(Theme.cardStroke, lineWidth: 1))
        .onAppear { animateBars = true }
    }
}

