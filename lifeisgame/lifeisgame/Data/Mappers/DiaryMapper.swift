//
//  DiaryMapper.swift
//  lifeisgame
//
//  Created by Codex on 08.05.2026.
//

import Foundation

enum DiaryMapper {

    static func emotionToDomain(_ entity: EmotionEntryEntity) -> EmotionDiaryEntry? {
        guard let id = entity.id,
              let emotionName = entity.emotionName,
              let sfSymbol = entity.sfSymbol,
              let dayDate = entity.dayDate,
              let createdAt = entity.createdAt,
              let ownerId = entity.owner?.id else {
            return nil
        }

        return EmotionDiaryEntry(
            id: id,
            emotionName: emotionName,
            sfSymbol: sfSymbol,
            reason: entity.reason,
            intensity: Int(entity.intensity),
            dayDate: dayDate,
            createdAt: createdAt,
            ownerId: ownerId
        )
    }

    static func sleepToDomain(_ entity: SleepEntryEntity) -> SleepDiaryEntry? {
        guard let id = entity.id,
              let dayDate = entity.dayDate,
              let bedtime = entity.bedtime,
              let wakeTime = entity.wakeTime,
              let createdAt = entity.createdAt,
              let ownerId = entity.owner?.id else {
            return nil
        }

        return SleepDiaryEntry(
            id: id,
            dayDate: dayDate,
            bedtime: bedtime,
            wakeTime: wakeTime,
            durationMinutes: Int(entity.durationMinutes),
            createdAt: createdAt,
            ownerId: ownerId
        )
    }
}
