//
//  AchievementLevelProgress.swift
//  lifeisgame
//
//  Уровень и звание, производные от открытых достижений.
//  Используется на экране достижений и в профиле.
//

import Foundation

struct AchievementLevelProgress {

    static let xpPerAchievement = 50
    static let xpPerLevel = 250
    static let ranks = ["Новичок", "Ученик", "Исследователь", "Тактик", "Стратег", "Мастер", "Легенда"]

    let collected: Int
    let total: Int

    init(items: [AchievementItem]) {
        collected = items.filter { $0.state == .opened }.count
        total = items.count
    }

    var totalXP: Int { collected * Self.xpPerAchievement }
    var level: Int { totalXP / Self.xpPerLevel + 1 }
    var rank: String { Self.ranks[min(level - 1, Self.ranks.count - 1)] }
    var xpInLevel: Int { totalXP % Self.xpPerLevel }
    var levelFraction: Double { Double(xpInLevel) / Double(Self.xpPerLevel) }
}
