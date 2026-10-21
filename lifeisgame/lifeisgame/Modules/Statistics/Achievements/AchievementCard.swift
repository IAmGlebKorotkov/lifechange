//
//  AchievementCard.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 21.05.2026.
//
//  Крупная карточка достижения для masonry-сетки: иконка, название,
//  описание цели и прогресс. Высота задаётся каталогом (Pinterest-стиль).
//

import SwiftUI

struct AchievementCard: View {

    let achievement: AchievementItem

    @State private var sheenPhase: CGFloat = -1.4
    @State private var openPulse = false

    private let cornerRadius: CGFloat = 22

    static func gradient(for kind: AchievementKind) -> LinearGradient {
        let colors: [Color]
        switch kind {
        case .tasks:
            colors = [Color(UIColor(rgb: 0x8A68F5)), Color(UIColor(rgb: 0x5F33E1))]
        case .sleep:
            colors = [Color(UIColor(rgb: 0x7EE2A0)), Color(UIColor(rgb: 0x1E9E63))]
        case .emotion:
            colors = [Color(UIColor(rgb: 0xFFCF6B)), Color(UIColor(rgb: 0xFF9F0A))]
        case .focus:
            colors = [Color(UIColor(rgb: 0x6BB7FF)), Color(UIColor(rgb: 0x0A84FF))]
        }
        return LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    static func gradientShadow(for kind: AchievementKind) -> Color {
        switch kind {
        case .tasks:   return Color(UIColor(rgb: 0x5F33E1))
        case .sleep:   return Color(UIColor(rgb: 0x30D158))
        case .emotion: return Color(UIColor(rgb: 0xFF9F0A))
        case .focus:   return Color(UIColor(rgb: 0x0A84FF))
        }
    }

    private var kindTint: Color {
        Self.gradientShadow(for: achievement.kind)
    }

    private var isColored: Bool {
        achievement.state != .locked
    }

    private var progressFraction: Double {
        guard achievement.targetValue > 0 else { return 0 }
        return min(1, Double(achievement.currentValue) / Double(achievement.targetValue))
    }

    var body: some View {
        ZStack {
            background

            if achievement.state == .unlocked {
                sheen
            }

            content
        }
        .frame(height: max(achievement.cellHeight, 150))
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .compositingGroup()
        .scaleEffect(openPulse ? 1.08 : 1)
        .shadow(
            color: isColored ? kindTint.opacity(0.32) : Color(UIColor(rgb: 0x2D2054)).opacity(0.08),
            radius: isColored ? 7 : 3,
            x: 0,
            y: isColored ? 4 : 2
        )
        .contentShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .onAppear {
            startSheenIfNeeded()
        }
        .onChange(of: achievement.state) { oldState, newState in
            startSheenIfNeeded()
            if oldState == .unlocked && newState == .opened {
                playOpenPulse()
            }
        }
    }

    private var background: some View {
        Group {
            if isColored {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Self.gradient(for: achievement.kind))
            } else {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(Color(UIColor(rgb: 0x3C3C43, alpha: 0.1)), lineWidth: 1)
                    )
            }
        }
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                iconTile
                Spacer(minLength: 6)
                statusBadge
            }

            Spacer(minLength: 10)

            Text(achievement.title)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(isColored ? .white : Color(.label))
                .lineLimit(2)
                .minimumScaleFactor(0.85)

            Text(achievement.goal)
                .font(.system(size: 12, weight: .regular))
                .foregroundStyle(isColored ? .white.opacity(0.78) : Color(UIColor.textSecondaryToken))
                .lineLimit(3)
                .padding(.top, 3)

            bottomSection
                .padding(.top, 10)
        }
        .padding(14)
    }

    private var iconTile: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(isColored ? .white.opacity(0.22) : kindTint.opacity(0.12))
                .frame(width: 40, height: 40)

            Image(systemName: achievement.icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(isColored ? .white : kindTint)
        }
    }

    private var statusBadge: some View {
        Group {
            switch achievement.state {
            case .locked:
                Image(systemName: "lock.fill")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color(UIColor(rgb: 0x3C3C43, alpha: 0.3)))
                    .frame(width: 26, height: 26)
                    .background(Color(UIColor(rgb: 0x3C3C43, alpha: 0.06)))
                    .clipShape(Circle())

            case .unlocked:
                EmptyView()

            case .opened:
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
            }
        }
    }

    private var bottomSection: some View {
        Group {
            switch achievement.state {
            case .locked:
                HStack(spacing: 8) {
                    GeometryReader { proxy in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(kindTint.opacity(0.14))

                            Capsule()
                                .fill(kindTint)
                                .frame(width: max(proxy.size.width * progressFraction, progressFraction > 0 ? 6 : 0))
                        }
                    }
                    .frame(height: 5)

                    Text(achievement.progress)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Color(UIColor.textSecondaryToken))
                        .fixedSize()
                }

            case .unlocked:
                HStack(spacing: 5) {
                    Image(systemName: "hand.tap.fill")
                        .font(.system(size: 10, weight: .semibold))
                    Text("Нажми, чтобы открыть")
                        .font(.system(size: 11, weight: .bold))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(.white.opacity(0.22))
                .clipShape(Capsule())

            case .opened:
                Text("+\(AchievementLevelProgress.xpPerAchievement) XP · собрано")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.white.opacity(0.9))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(.white.opacity(0.16))
                    .clipShape(Capsule())
            }
        }
    }

    private var sheen: some View {
        GeometryReader { proxy in
            let width = proxy.size.width

            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [.clear, .white.opacity(0.5), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: width * 0.45)
                .rotationEffect(.degrees(8))
                .offset(x: sheenPhase * width)
        }
        .allowsHitTesting(false)
    }

    private func playOpenPulse() {
        withAnimation(.spring(response: 0.28, dampingFraction: 0.55)) {
            openPulse = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                openPulse = false
            }
        }
    }

    private func startSheenIfNeeded() {
        sheenPhase = -1.4
        guard achievement.state == .unlocked else { return }

        withAnimation(.easeInOut(duration: 3.2).repeatForever(autoreverses: false).delay(0.6)) {
            sheenPhase = 2.4
        }
    }
}
