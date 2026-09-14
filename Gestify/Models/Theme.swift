//
//  Theme.swift
//  Gestify
//
//  Created by Ni Komang Ayu Juliana on 14/09/26.
//

import SwiftUI

enum Theme {
    static let backgroundGradient = LinearGradient(
        colors: [
            Color(red: 0.07, green: 0.05, blue: 0.12),
            Color(red: 0.02, green: 0.02, blue: 0.04)
        ],
        startPoint: .top, endPoint: .bottom
    )

    static let accentGradient = LinearGradient(
        colors: [
            Color(red: 0.58, green: 0.35, blue: 1.0),
            Color(red: 1.0, green: 0.38, blue: 0.62)
        ],
        startPoint: .leading, endPoint: .trailing
    )

    static let cardStroke = Color.white.opacity(0.1)
    static let cornerRadius: CGFloat = 24
}
