//
//  GestureTips.swift
//  Gestify
//
//  Created by Ni Komang Ayu Juliana on 14/09/26.
//

import SwiftUI
import TipKit

struct GestureTipStyle: TipViewStyle {
    func makeBody(configuration: TipViewStyleConfiguration) -> some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle().fill(Theme.accentGradient.opacity(0.85)).frame(width: 44, height: 44)
                configuration.image?
                    .foregroundStyle(.white)
                    .font(.system(size: 18, weight: .semibold))
            }
            VStack(alignment: .leading, spacing: 4) {
                configuration.title?.font(.subheadline.weight(.semibold)).foregroundStyle(.white)
                configuration.message?.font(.caption).foregroundStyle(.white.opacity(0.7))
            }
            Spacer()
//            Button {
//                configuration.tip.invalidate(reason: .tipClosed)
//            } label: {
//                Image(systemName: "xmark").font(.caption.weight(.bold)).foregroundStyle(.white.opacity(0.4))
//            }
        }
        .padding(14)
        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(.white.opacity(0.08), lineWidth: 1))
    }
}
