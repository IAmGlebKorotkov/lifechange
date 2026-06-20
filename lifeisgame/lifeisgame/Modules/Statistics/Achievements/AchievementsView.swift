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

    init(achievementService: AchievementService = AchievementService()) {
        _viewModel = StateObject(wrappedValue: AchievementsViewModel(achievementService: achievementService))
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
