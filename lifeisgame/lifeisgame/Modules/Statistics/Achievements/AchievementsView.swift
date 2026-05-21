//
//  AchievementsView.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.03.2026.
//

import SwiftUI
import Combine

struct AchievementsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: AchievementsViewModel

    init(repository: AchievementRepositoryProtocol = AchievementRepository()) {
        _viewModel = StateObject(wrappedValue: AchievementsViewModel(repository: repository))
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView(showsIndicators: false) {
                if viewModel.items.isEmpty {
                    emptyState
                        .padding(.top, 92)
                } else {
                    achievementGrid
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 36)
                }
            }
        }
        .background(Color(UIColor.background).ignoresSafeArea())
        .onAppear {
            viewModel.loadAchievements()
        }
    }

    private var header: some View {
        HStack {
            Text("Достижения")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(Color(.label))

            Spacer()

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color(.label))
                    .frame(width: 40, height: 40)
                    .background(Color(.systemGray5))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }

    private var achievementGrid: some View {
        let columns = masonryColumns

        return HStack(alignment: .top, spacing: 12) {
            ForEach(columns.indices, id: \.self) { index in
                LazyVStack(spacing: 12) {
                    ForEach(columns[index]) { achievement in
                        AchievementCard(achievement: achievement) {
                            viewModel.openAchievement(achievement)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    private var masonryColumns: [[AchievementItem]] {
        var columns = Array(repeating: [AchievementItem](), count: 2)
        var heights = Array(repeating: CGFloat.zero, count: 2)

        for item in viewModel.items {
            let index = heights[0] <= heights[1] ? 0 : 1
            columns[index].append(item)
            heights[index] += max(item.cellHeight, 145) + 12
        }

        return columns
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(Color(UIColor.main))

            Text("Достижения появятся позже")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color(.label))

            Text("Когда появится прогресс, карточки автоматически обновятся.")
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(Color(.secondaryLabel))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 36)
        }
    }
}


private final class AchievementsViewModel: ObservableObject {

    @Published private(set) var items: [AchievementItem] = []

    private let repository: AchievementRepositoryProtocol
    private var observerTokens: [NSObjectProtocol] = []

    init(repository: AchievementRepositoryProtocol) {
        self.repository = repository
        observeStoreChanges()
    }

    deinit {
        observerTokens.forEach(NotificationCenter.default.removeObserver)
    }

    func loadAchievements() {
        guard let userID = SessionManager.shared.currentUserID else {
            items = []
            return
        }

        do {
            items = try repository.fetchAchievements(forUserID: userID)
        } catch {
            items = []
        }
    }

    func openAchievement(_ item: AchievementItem) {
        guard item.state == .unlocked,
              let userID = SessionManager.shared.currentUserID,
              let index = items.firstIndex(where: { $0.id == item.id }) else { return }

        do {
            items[index] = try repository.markOpened(achievementID: item.id, forUserID: userID)
        } catch {
            loadAchievements()
        }
    }

    private func observeStoreChanges() {
        let names: [Notification.Name] = [
            .taskStoreDidChange,
            .diaryStoreDidChange,
            .focusSessionStoreDidChange,
            .achievementStoreDidChange
        ]

        observerTokens = names.map { name in
            NotificationCenter.default.addObserver(
                forName: name,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                self?.loadAchievements()
            }
        }
    }
}


private struct AchievementCard: View {

    let achievement: AchievementItem
    let onOpen: () -> Void

    @State private var isPressing = false
    @State private var pressProgress: CGFloat = 0
    @State private var isWobbling = false

    private let cornerRadius: CGFloat = 20

    var body: some View {
        ZStack {
            backgroundIcon

            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Spacer()
                    topBadge
                }

                Spacer(minLength: 8)

                icon
                    .frame(maxWidth: .infinity)

                Spacer(minLength: 10)

                Text(achievement.title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(titleColor)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(achievement.goal)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundStyle(goalColor)
                    .lineLimit(3)
                    .padding(.top, 3)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(12)
        }
        .frame(height: max(achievement.cellHeight, 145))
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .overlay(pressOverlay)
        .scaleEffect(isPressing ? 1.06 : 1)
        .rotationEffect(wobbleAngle)
        .shadow(color: .black.opacity(achievement.state == .opened ? 0.05 : 0.02), radius: 8, x: 0, y: 2)
        .contentShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .onLongPressGesture(minimumDuration: 3, maximumDistance: 44) {
            guard achievement.state == .unlocked else { return }
            resetPress()
            onOpen()
        } onPressingChanged: { isPressing in
            guard achievement.state == .unlocked else { return }
            isPressing ? startPress() : resetPress()
        }
        .onAppear {
            startWobbleIfNeeded()
        }
        .onChange(of: achievement.state) { _, _ in
            resetPress()
            startWobbleIfNeeded()
        }
        .animation(.spring(response: 0.25, dampingFraction: 0.76), value: isPressing)
    }

    private var topBadge: some View {
        Group {
            if achievement.state == .opened {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(Color(UIColor.main))
            } else {
                Text(achievement.progress)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(badgeTextColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(badgeBackground)
                    .clipShape(Capsule())
            }
        }
    }

    private var icon: some View {
        ZStack {
            if achievement.state == .locked {
                Image(systemName: "lock.fill")
                    .font(.system(size: 28, weight: .medium))
                    .foregroundStyle(Color.white.opacity(0.55))
            } else {
                if achievement.state == .opened {
                    Circle()
                        .fill(Color(UIColor.main).opacity(0.10))
                        .frame(width: 56, height: 56)
                }

                Image(systemName: achievement.icon)
                    .font(.system(size: 36, weight: .medium))
                    .foregroundStyle(iconColor)
            }
        }
    }

    private var backgroundIcon: some View {
        Group {
            if achievement.state != .opened {
                Image(systemName: achievement.icon)
                    .font(.system(size: 82, weight: .medium))
                    .foregroundStyle(Color.white.opacity(achievement.state == .locked ? 0.05 : 0.08))
                    .rotationEffect(.degrees(15))
                    .offset(x: 28, y: -4)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
            }
        }
    }

    private var pressOverlay: some View {
        Group {
            if achievement.state == .unlocked && isPressing {
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(Color.white.opacity(0.18), lineWidth: 4)

                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .trim(from: 0, to: pressProgress)
                        .stroke(Color.white.opacity(0.35), style: StrokeStyle(lineWidth: 10, lineCap: .round))

                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .trim(from: 0, to: pressProgress)
                        .stroke(Color.white, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                }
                .padding(3)
            }
        }
    }

    private var cardBackground: Color {
        switch achievement.state {
        case .locked:
            return Color(red: 0.12, green: 0.12, blue: 0.12)
        case .unlocked:
            return Color(UIColor.main)
        case .opened:
            return .white
        }
    }

    private var iconColor: Color {
        achievement.state == .opened ? Color(UIColor.main) : .white
    }

    private var titleColor: Color {
        switch achievement.state {
        case .locked:
            return Color.white.opacity(0.65)
        case .unlocked:
            return .white
        case .opened:
            return Color(.label)
        }
    }

    private var goalColor: Color {
        switch achievement.state {
        case .locked:
            return Color.white.opacity(0.38)
        case .unlocked:
            return Color.white.opacity(0.70)
        case .opened:
            return Color(.secondaryLabel)
        }
    }

    private var badgeTextColor: Color {
        achievement.state == .locked ? Color.white.opacity(0.50) : .white
    }

    private var badgeBackground: Color {
        achievement.state == .locked ? Color.white.opacity(0.08) : Color.white.opacity(0.20)
    }

    private var wobbleAngle: Angle {
        guard achievement.state == .unlocked && !isPressing else { return .zero }
        return .degrees(isWobbling ? 1.05 : -1.05)
    }

    private func startPress() {
        isPressing = true
        pressProgress = 0
        withAnimation(.linear(duration: 3)) {
            pressProgress = 1
        }
    }

    private func resetPress() {
        isPressing = false
        pressProgress = 0
    }

    private func startWobbleIfNeeded() {
        guard achievement.state == .unlocked else {
            isWobbling = false
            return
        }

        withAnimation(.easeInOut(duration: 0.55).repeatForever(autoreverses: true)) {
            isWobbling = true
        }
    }
}
