//
//  AchievementMapper.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 12.05.2026.
//

import CoreGraphics
import Foundation

enum AchievementMapper {
    static func toDomain(_ entity: AchievementEntity) -> AchievementItem? {
        guard let id = entity.id,
              let code = entity.code,
              let kindValue = entity.kind,
              let kind = AchievementKind(rawValue: kindValue),
              let icon = entity.icon,
              let title = entity.title,
              let goal = entity.goal else { return nil }

        let state = AchievementState(rawValue: entity.state ?? "") ?? .locked
        return AchievementItem(
            id: id,
            code: code,
            kind: kind,
            icon: icon,
            title: title,
            goal: goal,
            currentValue: Int(entity.currentValue),
            targetValue: max(1, Int(entity.targetValue)),
            state: state,
            cellHeight: CGFloat(entity.cellHeight == 0 ? 160 : entity.cellHeight),
            unlockedAt: entity.unlockedAt,
            openedAt: entity.openedAt
        )
    }
}
