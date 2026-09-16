//
//  OnboardingView.swift
//  Gestify
//
//  Created by Ni Komang Ayu Juliana on 16/09/26.
//

import SwiftUI

struct OnboardingPage: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let message: String
}

struct OnboardingView: View {
    var onFinish: () -> Void

    @State private var currentPage = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "hand.wave.fill",
            title: "Welcome to Gestify",
            message: "Control the music you're playing with just a wave of your hand — no need to touch the screen."
        ),
        OnboardingPage(
            icon: "camera.viewfinder",
            title: "Point your camera",
            message: "Use the flip button to switch between the front and back camera, then hold your hand up in front of the lens."
        ),
        OnboardingPage(
            icon: "hand.raised.fill",
            title: "One gesture, one command",
            message: "Open palm to play, fist to pause, and more to skip tracks. Detection results show up instantly on screen."
        )
    ]

    var body: some View {
        ZStack {
            Theme.backgroundGradient.ignoresSafeArea()

            VStack(spacing: 0) {
                skipButton

                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.element.id) { index, page in
                        pageView(page).tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)

                pageIndicator
                    .padding(.bottom, 28)

                continueButton
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
            }
        }
        .preferredColorScheme(.dark)
    }

    private var skipButton: some View {
        HStack {
            Spacer()
            Button("Skip", action: finish)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.white.opacity(0.4))
                .padding(.top, 12)
                .padding(.trailing, 20)
        }
        .buttonStyle(.glass)
    }

    private func pageView(_ page: OnboardingPage) -> some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Theme.accentGradient.opacity(0.18))
                    .frame(width: 160, height: 160)
                Circle()
                    .fill(Theme.accentGradient)
                    .frame(width: 104, height: 104)
                Image(systemName: page.icon)
                    .font(.system(size: 42, weight: .semibold))
                    .foregroundStyle(.white)
            }

            VStack(spacing: 10) {
                Text(page.title)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                Text(page.message)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 36)
            }

            Spacer()
            Spacer()
        }
    }

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(pages.indices, id: \.self) { index in
                Capsule()
                    .fill(index == currentPage ? AnyShapeStyle(Theme.accentGradient) : AnyShapeStyle(Color.white.opacity(0.2)))
                    .frame(width: index == currentPage ? 20 : 6, height: 6)
                    .animation(.easeInOut(duration: 0.25), value: currentPage)
            }
        }
    }

    private var continueButton: some View {
        Button {
            if currentPage < pages.count - 1 {
                withAnimation { currentPage += 1 }
            } else {
                finish()
            }
        } label: {
            Text(currentPage < pages.count - 1 ? "Next" : "Get Started")
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .fontWeight(.semibold)
        }
        .background(Theme.accentGradient, in: RoundedRectangle(cornerRadius: 16))
        .foregroundStyle(.white)
    }

    private func finish() {
        OnboardingParameters.hasCompletedOnboarding = true
        onFinish()
    }
}

#Preview {
    OnboardingView(onFinish: {})
}
