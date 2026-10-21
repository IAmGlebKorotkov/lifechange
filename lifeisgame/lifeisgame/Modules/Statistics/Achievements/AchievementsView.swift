//
//  AchievementsView.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.03.2026.
//

import SwiftUI

struct AchievementsView: View {

    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: AchievementsViewModel
    @State private var detailID: UUID?
    @State private var detailSourceFrame: CGRect = .zero

    init(achievementService: AchievementService = AchievementService()) {
        _viewModel = StateObject(wrappedValue: AchievementsViewModel(achievementService: achievementService))
    }

    private var levelProgress: AchievementLevelProgress {
        AchievementLevelProgress(items: viewModel.items)
    }

    private var newestUnlocked: AchievementItem? {
        viewModel.items
            .filter { $0.state == .unlocked }
            .sorted { ($0.unlockedAt ?? .distantPast) > ($1.unlockedAt ?? .distantPast) }
            .first
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                header

                ScrollView(showsIndicators: false) {
                    if viewModel.items.isEmpty {
                        emptyState
                            .padding(.top, 92)
                    } else {
                        VStack(spacing: 20) {
                            levelCard

                            if let newest = newestUnlocked {
                                newAchievementToast(newest)
                            }

                            achievementGrid
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 14)
                        .padding(.bottom, 36)
                    }
                }
            }

            if let detailID, let item = viewModel.items.first(where: { $0.id == detailID }) {
                AchievementDetailOverlay(
                    achievement: item,
                    sourceFrame: detailSourceFrame,
                    onCollect: { viewModel.openAchievement(item) },
                    onDismiss: { self.detailID = nil }
                )
                .ignoresSafeArea()
            }
        }
        .background(Color(UIColor.background).ignoresSafeArea())
        .onAppear {
            viewModel.loadAchievements()
        }
        .alert(
            "Не получилось",
            isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { isPresented in
                    if !isPresented { viewModel.errorMessage = nil }
                }
            )
        ) {
            Button("Ок", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "Попробуйте ещё раз")
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 1) {
                Text("Достижения")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(Color(.label))

                Text("Собрано \(levelProgress.collected) из \(levelProgress.total)")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(Color(UIColor.textSecondaryToken))
            }

            Spacer()

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color(.label))
                    .frame(width: 38, height: 38)
                    .background(.white)
                    .clipShape(Circle())
                    .shadow(color: Color(UIColor(rgb: 0x2D2054)).opacity(0.12), radius: 5, x: 0, y: 2)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 22)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }

    private var levelCard: some View {
        VStack(spacing: 11) {
            HStack {
                Text("Уровень \(levelProgress.level) · \(levelProgress.rank)")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)

                Spacer()

                Text("\(levelProgress.xpInLevel) / \(AchievementLevelProgress.xpPerLevel) XP")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(.white.opacity(0.55))
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(.white.opacity(0.14))

                    Capsule()
                        .fill(Color(UIColor.main))
                        .frame(width: proxy.size.width * levelProgress.levelFraction)
                }
            }
            .frame(height: 8)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .background(Color(UIColor.inkDark))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func newAchievementToast(_ item: AchievementItem) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .fill(AchievementCard.gradient(for: item.kind))
                    .frame(width: 50, height: 50)
                    .shadow(color: AchievementCard.gradientShadow(for: item.kind).opacity(0.5), radius: 8, x: 0, y: 5)

                Image(systemName: item.icon)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("НОВАЯ АЧИВКА")
                    .font(.system(size: 12, weight: .semibold))
                    .kerning(0.6)
                    .foregroundStyle(Color(UIColor.main))

                Text("Открыто «\(item.title)»")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color(.label))
                    .lineLimit(1)

                Text("+\(AchievementLevelProgress.xpPerAchievement) XP · нажмите на плитку, чтобы забрать")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(Color(UIColor.textSecondaryToken))
                    .lineLimit(1)
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: Color(UIColor(rgb: 0x2D2054)).opacity(0.14), radius: 8, x: 0, y: 4)
    }

    private var achievementGrid: some View {
        let columns = masonryColumns

        return HStack(alignment: .top, spacing: 13) {
            ForEach(columns.indices, id: \.self) { index in
                LazyVStack(spacing: 13) {
                    ForEach(columns[index]) { achievement in
                        AchievementCard(achievement: achievement)
                            .overlay(
                                GeometryReader { geo in
                                    Color.clear
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            detailSourceFrame = geo.frame(in: .global)
                                            detailID = achievement.id
                                        }
                                }
                            )
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    /// Раскладка Pinterest: карточка уходит в колонку с меньшей высотой.
    private var masonryColumns: [[AchievementItem]] {
        var columns = Array(repeating: [AchievementItem](), count: 2)
        var heights = Array(repeating: CGFloat.zero, count: 2)

        for item in viewModel.items {
            let index = heights[0] <= heights[1] ? 0 : 1
            columns[index].append(item)
            heights[index] += max(item.cellHeight, 150) + 13
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
