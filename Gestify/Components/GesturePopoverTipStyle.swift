//
//  GesturePopoverTipStyle.swift
//  Gestify
//
//  Created by Ni Komang Ayu Juliana on 16/09/26.
//

import SwiftUI
import TipKit

struct GesturePopoverTipStyle: TipViewStyle {
    func makeBody(configuration: TipViewStyleConfiguration) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                if let image = configuration.image {
                    ZStack {
                        Circle()
                            .fill(Theme.accentGradient)
                            .frame(width: 34, height: 34)
                        image
                            .foregroundStyle(.white)
                            .font(.system(size: 14, weight: .semibold))
                    }
                }

                VStack(alignment: .leading, spacing: 3) {
                    configuration.title?
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                    configuration.message?
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
//                       .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)

                Button {
                    configuration.tip.invalidate(reason: .tipClosed)
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white.opacity(0.6))
                        .padding(6)
                        .background(.white.opacity(0.08), in: Circle())
                }
                .buttonStyle(.plain)
            }

            if !configuration.actions.isEmpty {
                Divider().overlay(Color.white.opacity(0.1))
                HStack(spacing: 16) {
                    ForEach(configuration.actions) { action in
                        Button(action: action.handler) {
                            action.label()
                        }
                        .font(.caption.weight(.semibold))
//                        .foregroundStyle(Color(red: 0.78, green: 0.62, blue: 1.0))
                    }
                }
            }
        }
        .padding(14)
//        .background(Color(red: 0.09, green: 0.07, blue: 0.15), in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.cardStroke, lineWidth: 1))
        .presentationBackground(.clear)
        .presentationCompactAdaptation(.none)
    }
    
}
