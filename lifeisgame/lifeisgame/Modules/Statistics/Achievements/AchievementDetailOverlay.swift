//
//  AchievementDetailOverlay.swift
//  lifeisgame
//
//  Развёрнутая карточка достижения: вырастает из карточки в сетке,
//  вращается пальцем (drag) и наклоном телефона (CoreMotion).
//

import SwiftUI
import Combine
import CoreMotion

struct AchievementDetailOverlay: View {

    let achievement: AchievementItem
    let sourceFrame: CGRect
    let onCollect: () -> Void
    let onDismiss: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var expanded = false
    @State private var isDismissing = false
    @State private var dragTilt: CGSize = .zero
    @StateObject private var motion = MotionTiltManager()

    private var isColored: Bool {
        achievement.state != .locked
    }

    private var kindTint: Color {
        AchievementCard.gradientShadow(for: achievement.kind)
    }

    private var progressFraction: Double {
        guard achievement.targetValue > 0 else { return 0 }
        return min(1, Double(achievement.currentValue) / Double(achievement.targetValue))
    }

    private var tiltX: Double {
        let value = -Double(dragTilt.height) / 6 + motion.pitchDegrees * 0.55
        return max(-16, min(16, value))
    }

    private var tiltY: Double {
        let value = Double(dragTilt.width) / 6 + motion.rollDegrees * 0.55
        return max(-16, min(16, value))
    }

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            let cardWidth = size.width - 48
            let cardHeight = min(size.height * 0.66, 540)

            ZStack {
                Color.black.opacity(expanded && !isDismissing ? 0.45 : 0)
                    .ignoresSafeArea()
                    .onTapGesture { dismiss() }

                detailCard
                    .frame(width: cardWidth, height: cardHeight)
                    .rotation3DEffect(.degrees(tiltX), axis: (x: 1, y: 0, z: 0))
                    .rotation3DEffect(.degrees(tiltY), axis: (x: 0, y: 1, z: 0))
                    .scaleEffect(
                        isDismissing
                            ? 0.06
                            : (expanded ? 1 : startScale(cardWidth: cardWidth))
                    )
                    .opacity(isDismissing ? 0 : 1)
                    .position(
                        expanded
                            ? CGPoint(x: size.width / 2, y: size.height / 2)
                            : CGPoint(x: sourceFrame.midX, y: sourceFrame.midY)
                    )
                    .gesture(tiltGesture)
            }
        }
        .allowsHitTesting(!isDismissing)
        .onAppear {
            motion.start()
            guard !reduceMotion else {
                expanded = true
                return
            }
            withAnimation(.spring(response: 0.45, dampingFraction: 0.82)) {
                expanded = true
            }
        }
        .onDisappear {
            motion.stop()
        }
    }

    private var tiltGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                dragTilt = value.translation
            }
            .onEnded { _ in
                withAnimation(.spring(response: 0.4, dampingFraction: 0.65)) {
                    dragTilt = .zero
                }
            }
    }

    private func startScale(cardWidth: CGFloat) -> CGFloat {
        guard cardWidth > 0, sourceFrame.width > 0 else { return 0.3 }
        return max(sourceFrame.width / cardWidth, 0.2)
    }

    private func dismiss() {
        guard !isDismissing else { return }
        motion.stop()

        guard !reduceMotion else {
            onDismiss()
            return
        }

        withAnimation(
            .easeInOut(duration: 0.48),
            completionCriteria: .removed
        ) {
            isDismissing = true
            dragTilt = .zero
        } completion: {
            onDismiss()
        }
    }


    private var detailCard: some View {
        ZStack {
            background

            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top) {
                    stateChip
                    Spacer()
                    closeButton
                }

                Spacer(minLength: 12)

                HStack {
                    Spacer()
                    iconTile
                    Spacer()
                }

                Spacer(minLength: 14)

                Text(achievement.title)
                    .font(.system(size: 25, weight: .bold))
                    .foregroundStyle(isColored ? .white : Color(.label))
                    .lineLimit(3)
                    .minimumScaleFactor(0.8)

                Text(achievement.goal)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(isColored ? .white.opacity(0.85) : Color(UIColor.textSecondaryToken))
                    .lineSpacing(3)
                    .padding(.top, 6)

                progressSection
                    .padding(.top, 16)

                actionSection
                    .padding(.top, 14)
            }
            .padding(22)
        }
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .compositingGroup()
        .shadow(
            color: isColored ? kindTint.opacity(0.45) : Color(UIColor(rgb: 0x2D2054)).opacity(0.22),
            radius: 16,
            x: 0,
            y: 10
        )
    }

    private var background: some View {
        Group {
            if isColored {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(AchievementCard.gradient(for: achievement.kind))
            } else {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(.white)
            }
        }
    }

    private var iconTile: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(isColored ? .white.opacity(0.22) : kindTint.opacity(0.12))
                .frame(width: 96, height: 96)

            Image(systemName: achievement.state == .locked ? "lock.fill" : achievement.icon)
                .font(.system(size: 42, weight: .medium))
                .foregroundStyle(isColored ? .white : kindTint.opacity(0.8))
        }
    }

    private var stateChip: some View {
        Group {
            switch achievement.state {
            case .locked:
                chip(text: "Ещё закрыто", icon: "lock.fill",
                     foreground: Color(UIColor.textSecondaryToken),
                     background: Color(UIColor(rgb: 0x3C3C43, alpha: 0.07)))
            case .unlocked:
                chip(text: "Готово к открытию", icon: "sparkles",
                     foreground: .white, background: .white.opacity(0.22))
            case .opened:
                chip(text: "Собрано", icon: "checkmark.seal.fill",
                     foreground: .white, background: .white.opacity(0.22))
            }
        }
    }

    private func chip(text: String, icon: String, foreground: Color, background: Color) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .semibold))
            Text(text)
                .font(.system(size: 12, weight: .bold))
        }
        .foregroundStyle(foreground)
        .padding(.horizontal, 11)
        .padding(.vertical, 6)
        .background(background)
        .clipShape(Capsule())
    }

    private var closeButton: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "xmark")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(isColored ? .white : Color(.label))
                .frame(width: 32, height: 32)
                .background(isColored ? .white.opacity(0.22) : Color(UIColor(rgb: 0x3C3C43, alpha: 0.07)))
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }

    private var progressSection: some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack {
                Text("Прогресс")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(isColored ? .white.opacity(0.7) : Color(UIColor.textSecondaryToken))

                Spacer()

                Text("\(min(achievement.currentValue, achievement.targetValue)) / \(achievement.targetValue)")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(isColored ? .white : Color(.label))
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(isColored ? .white.opacity(0.2) : kindTint.opacity(0.14))

                    Capsule()
                        .fill(isColored ? .white : kindTint)
                        .frame(width: max(proxy.size.width * progressFraction, progressFraction > 0 ? 8 : 0))
                }
            }
            .frame(height: 8)
        }
    }

    private var actionSection: some View {
        Group {
            switch achievement.state {
            case .unlocked:
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        onCollect()
                    }
                } label: {
                    Text("Забрать +\(AchievementLevelProgress.xpPerAchievement) XP")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(kindTint)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .buttonStyle(.plain)

            case .opened:
                Text("+\(AchievementLevelProgress.xpPerAchievement) XP уже в копилке")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.85))
                    .frame(maxWidth: .infinity)

            case .locked:
                Text("Выполните цель — карточка станет цветной")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color(UIColor.textSecondaryToken))
                    .frame(maxWidth: .infinity)
            }
        }
    }
}


// MARK: - Наклон устройства

final class MotionTiltManager: ObservableObject {

    @Published private(set) var pitchDegrees: Double = 0
    @Published private(set) var rollDegrees: Double = 0

    private let manager = CMMotionManager()
    private var basePitch: Double?
    private var baseRoll: Double?

    func start() {
        guard manager.isDeviceMotionAvailable else { return }
        manager.deviceMotionUpdateInterval = 1.0 / 30.0
        manager.startDeviceMotionUpdates(to: .main) { [weak self] deviceMotion, _ in
            guard let self, let attitude = deviceMotion?.attitude else { return }

            if self.basePitch == nil {
                self.basePitch = attitude.pitch
                self.baseRoll = attitude.roll
            }

            let pitch = (attitude.pitch - (self.basePitch ?? 0)) * 180 / .pi
            let roll = (attitude.roll - (self.baseRoll ?? 0)) * 180 / .pi

            // Публикуем только заметные изменения, чтобы не перерисовывать
            // экран на каждом микродвижении гироскопа.
            if abs(pitch - self.pitchDegrees) > 0.35 || abs(roll - self.rollDegrees) > 0.35 {
                self.pitchDegrees = pitch
                self.rollDegrees = roll
            }
        }
    }

    func stop() {
        manager.stopDeviceMotionUpdates()
        basePitch = nil
        baseRoll = nil
        pitchDegrees = 0
        rollDegrees = 0
    }
}
