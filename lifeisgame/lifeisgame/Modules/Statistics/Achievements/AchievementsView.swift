//
//  AchievementsView.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.03.2026.
//

import SwiftUI

struct AchievementsView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Text("Достижения")
                    .font(.title2.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 20)

                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(Achievement.placeholders) { achievement in
                            AchievementRow(achievement: achievement)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}


private struct AchievementRow: View {
    let achievement: Achievement

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(achievement.unlocked ? Color.accentColor.opacity(0.12) : Color(.systemGray5))
                    .frame(width: 52, height: 52)
                Image(systemName: achievement.icon)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(achievement.unlocked ? Color.accentColor : Color(.systemGray3))
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(achievement.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(achievement.unlocked ? .primary : .secondary)
                Text(achievement.subtitle)
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if achievement.unlocked {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundStyle(Color.accentColor)
            }
        }
        .padding(14)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}


private struct Achievement: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let subtitle: String
    let unlocked: Bool

    static let placeholders: [Achievement] = [
        .init(icon: "flame.fill",       title: "Первый шаг",       subtitle: "Выполни первую задачу",           unlocked: true),
        .init(icon: "star.fill",        title: "Неделя побед",     subtitle: "7 дней без пропусков",            unlocked: true),
        .init(icon: "moon.fill",        title: "Сладкий сон",      subtitle: "Спи 8 часов 5 дней подряд",      unlocked: false),
        .init(icon: "bolt.fill",        title: "Суперэффективность", subtitle: "Эффективность 90% за неделю",  unlocked: false),
        .init(icon: "heart.fill",       title: "Хорошее настроение", subtitle: "Отличное настроение 7 дней",   unlocked: false),
        .init(icon: "trophy.fill",      title: "Чемпион",          subtitle: "Выполни 100 задач",              unlocked: false),
    ]
}
