//
//  AchievementItem.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 19.05.2026.
//

import CoreGraphics
import Foundation

extension Notification.Name {
    static let achievementStoreDidChange = Notification.Name("achievementStoreDidChange")
    static let focusSessionStoreDidChange = Notification.Name("focusSessionStoreDidChange")
}

enum AchievementKind: String {
    case sleep
    case emotion
    case focus
    case tasks
}

enum AchievementState: String {
    case locked
    case unlocked
    case opened
}

struct AchievementItem: Equatable, Identifiable {
    let id: UUID
    let code: String
    let kind: AchievementKind
    let icon: String
    let title: String
    let goal: String
    let currentValue: Int
    let targetValue: Int
    var state: AchievementState
    let cellHeight: CGFloat
    let unlockedAt: Date?
    let openedAt: Date?

    var progress: String {
        "\(min(currentValue, targetValue))/\(targetValue)"
    }
}
