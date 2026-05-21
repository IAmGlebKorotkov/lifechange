//
//  AchievementRepository.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 19.05.2026.
//

import Foundation
import CoreData

final class AchievementRepository: AchievementRepositoryProtocol {

    private let persistence: PersistenceController
    private let calendar: Calendar

    init(persistence: PersistenceController = .shared,
         calendar: Calendar = .current) {
        self.persistence = persistence
        self.calendar = calendar
    }

    func fetchAchievements(forUserID userID: UUID) throws -> [AchievementItem] {
        guard let owner = try fetchUserEntity(id: userID) else {
            throw RepositoryError.notFound
        }

        try seedAchievementsIfNeeded(for: owner)
        try refreshProgress(for: owner, userID: userID)
        persistence.save()

        return try fetchAchievementEntities(forUserID: userID).compactMap {
            AchievementMapper.toDomain($0)
        }
    }

    @discardableResult
    func markOpened(achievementID: UUID, forUserID userID: UUID) throws -> AchievementItem {
        guard let entity = try fetchAchievementEntity(id: achievementID, userID: userID) else {
            throw RepositoryError.notFound
        }

        let state = AchievementState(rawValue: entity.state ?? "") ?? .locked
        if state == .unlocked || state == .opened || entity.unlockedAt != nil {
            entity.openedAt = entity.openedAt ?? Date()
            entity.state = AchievementState.opened.rawValue
        }

        persistence.save()
        NotificationCenter.default.post(name: .achievementStoreDidChange, object: nil)

        guard let item = AchievementMapper.toDomain(entity) else {
            throw RepositoryError.mappingFailed
        }
        return item
    }

    func recordFocusSession(forUserID userID: UUID, taskID: UUID?, startedAt: Date, endedAt: Date) throws {
        guard endedAt > startedAt else { return }
        guard let owner = try fetchUserEntity(id: userID) else {
            throw RepositoryError.notFound
        }

        let duration = endedAt.timeIntervalSince(startedAt)
        let entity = FocusSessionEntity(context: persistence.context)
        entity.id = UUID()
        entity.startedAt = startedAt
        entity.endedAt = endedAt
        entity.durationSeconds = duration
        entity.taskID = taskID
        entity.createdAt = Date()
        entity.owner = owner

        persistence.save()
        _ = try fetchAchievements(forUserID: userID)
        NotificationCenter.default.post(name: .focusSessionStoreDidChange, object: nil)
        NotificationCenter.default.post(name: .achievementStoreDidChange, object: nil)
    }

    private func seedAchievementsIfNeeded(for owner: UserEntity) throws {
        let existingByCode = achievementsByCode(owner.achievementsArray)

        for definition in Self.definitions {
            let entity = existingByCode[definition.code] ?? AchievementEntity(context: persistence.context)
            if entity.id == nil {
                entity.id = UUID()
                entity.createdAt = Date()
                entity.currentValue = 0
                entity.state = AchievementState.locked.rawValue
                entity.owner = owner
            }

            entity.code = definition.code
            entity.kind = definition.kind.rawValue
            entity.icon = definition.icon
            entity.title = definition.title
            entity.goal = definition.goal
            entity.targetValue = Int32(definition.targetValue)
            entity.cellHeight = definition.cellHeight
            entity.sortOrder = Int16(definition.sortOrder)
        }
    }

    private func refreshProgress(for owner: UserEntity, userID: UUID) throws {
        let metrics = try achievementMetrics(forUserID: userID)
        let entitiesByCode = achievementsByCode(owner.achievementsArray)

        for definition in Self.definitions {
            guard let entity = entitiesByCode[definition.code] else { continue }
            let currentValue = max(0, definition.progress(metrics))
            entity.currentValue = Int32(currentValue)

            let existingState = AchievementState(rawValue: entity.state ?? "") ?? .locked
            if entity.openedAt != nil || existingState == .opened {
                entity.state = AchievementState.opened.rawValue
            } else if entity.unlockedAt != nil || currentValue >= definition.targetValue {
                entity.unlockedAt = entity.unlockedAt ?? Date()
                entity.state = AchievementState.unlocked.rawValue
            } else {
                entity.state = AchievementState.locked.rawValue
            }
        }
    }

    private func achievementMetrics(forUserID userID: UUID) throws -> AchievementMetrics {
        let completedTasksRequest = TaskEntity.fetchRequest()
        completedTasksRequest.predicate = NSPredicate(
            format: "owner.id == %@ AND isCompleted == YES",
            userID as CVarArg
        )
        let completedTasks = try persistence.context.count(for: completedTasksRequest)

        let sleepRequest = SleepEntryEntity.fetchRequest()
        sleepRequest.predicate = NSPredicate(format: "owner.id == %@", userID as CVarArg)
        let sleepEntries = try persistence.context.fetch(sleepRequest)
        let sleepEntryDays = uniqueDays(sleepEntries.compactMap(\.dayDate)).count
        let eightHourSleepDays = uniqueDays(
            sleepEntries
                .filter { $0.durationMinutes >= 480 }
                .compactMap(\.dayDate)
        ).count

        let emotionRequest = EmotionEntryEntity.fetchRequest()
        emotionRequest.predicate = NSPredicate(format: "owner.id == %@", userID as CVarArg)
        let emotionEntries = try persistence.context.fetch(emotionRequest)
        let emotionEntryDays = uniqueDays(emotionEntries.compactMap(\.dayDate)).count
        let highIntensityEmotionDays = uniqueDays(
            emotionEntries
                .filter { $0.intensity >= 8 }
                .compactMap(\.dayDate)
        ).count

        let focusRequest = FocusSessionEntity.fetchRequest()
        focusRequest.predicate = NSPredicate(format: "owner.id == %@", userID as CVarArg)
        let focusSessions = try persistence.context.fetch(focusRequest)
        let focusSeconds = focusSessions.reduce(0) { $0 + max(0, $1.durationSeconds) }

        return AchievementMetrics(
            completedTasks: completedTasks,
            sleepEntryDays: sleepEntryDays,
            eightHourSleepDays: eightHourSleepDays,
            emotionEntryDays: emotionEntryDays,
            highIntensityEmotionDays: highIntensityEmotionDays,
            focusHours: Int(focusSeconds / 3600)
        )
    }

    private func uniqueDays(_ dates: [Date]) -> Set<Date> {
        Set(dates.map { calendar.startOfDay(for: $0) })
    }

    private func achievementsByCode(_ achievements: [AchievementEntity]) -> [String: AchievementEntity] {
        var result: [String: AchievementEntity] = [:]
        for entity in achievements {
            guard let code = entity.code, result[code] == nil else { continue }
            result[code] = entity
        }
        return result
    }

    private func fetchUserEntity(id: UUID) throws -> UserEntity? {
        let request = UserEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        return try persistence.context.fetch(request).first
    }

    private func fetchAchievementEntity(id: UUID, userID: UUID) throws -> AchievementEntity? {
        let request = AchievementEntity.fetchRequest()
        request.predicate = NSPredicate(
            format: "id == %@ AND owner.id == %@",
            id as CVarArg,
            userID as CVarArg
        )
        request.fetchLimit = 1
        return try persistence.context.fetch(request).first
    }

    private func fetchAchievementEntities(forUserID userID: UUID) throws -> [AchievementEntity] {
        let request = AchievementEntity.fetchRequest()
        request.predicate = NSPredicate(format: "owner.id == %@", userID as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(key: "sortOrder", ascending: true)]
        return try persistence.context.fetch(request)
    }
}

private struct AchievementMetrics {
    let completedTasks: Int
    let sleepEntryDays: Int
    let eightHourSleepDays: Int
    let emotionEntryDays: Int
    let highIntensityEmotionDays: Int
    let focusHours: Int
}

private struct AchievementDefinition {
    let code: String
    let kind: AchievementKind
    let icon: String
    let title: String
    let goal: String
    let targetValue: Int
    let sortOrder: Int
    let cellHeight: Double
    let progress: (AchievementMetrics) -> Int
}

private extension AchievementRepository {
    static let definitions: [AchievementDefinition] = [
        AchievementDefinition(
            code: "tasks_1",
            kind: .tasks,
            icon: "flame.fill",
            title: "Первый шаг",
            goal: "Выполни первое задание",
            targetValue: 1,
            sortOrder: 0,
            cellHeight: 160,
            progress: { $0.completedTasks }
        ),
        AchievementDefinition(
            code: "sleep_1",
            kind: .sleep,
            icon: "moon.fill",
            title: "Сон записан",
            goal: "Добавь первую запись сна",
            targetValue: 1,
            sortOrder: 1,
            cellHeight: 185,
            progress: { $0.sleepEntryDays }
        ),
        AchievementDefinition(
            code: "emotion_1",
            kind: .emotion,
            icon: "heart.fill",
            title: "На связи с собой",
            goal: "Добавь первую эмоцию в дневник",
            targetValue: 1,
            sortOrder: 2,
            cellHeight: 150,
            progress: { $0.emotionEntryDays }
        ),
        AchievementDefinition(
            code: "focus_1",
            kind: .focus,
            icon: "brain.head.profile",
            title: "Первый фокус",
            goal: "Проведи 1 час в фокусе",
            targetValue: 1,
            sortOrder: 3,
            cellHeight: 155,
            progress: { $0.focusHours }
        ),
        AchievementDefinition(
            code: "tasks_10",
            kind: .tasks,
            icon: "checkmark.seal.fill",
            title: "Вошел в ритм",
            goal: "Выполни 10 заданий",
            targetValue: 10,
            sortOrder: 4,
            cellHeight: 170,
            progress: { $0.completedTasks }
        ),
        AchievementDefinition(
            code: "sleep_8h_5",
            kind: .sleep,
            icon: "bed.double.fill",
            title: "Сладкий сон",
            goal: "Спи не меньше 8 часов 5 дней",
            targetValue: 5,
            sortOrder: 5,
            cellHeight: 185,
            progress: { $0.eightHourSleepDays }
        ),
        AchievementDefinition(
            code: "emotion_7",
            kind: .emotion,
            icon: "sparkles",
            title: "Неделя эмоций",
            goal: "Отмечай эмоции 7 разных дней",
            targetValue: 7,
            sortOrder: 6,
            cellHeight: 165,
            progress: { $0.emotionEntryDays }
        ),
        AchievementDefinition(
            code: "focus_10",
            kind: .focus,
            icon: "bolt.fill",
            title: "Глубокая работа",
            goal: "Накопи 10 часов фокуса",
            targetValue: 10,
            sortOrder: 7,
            cellHeight: 145,
            progress: { $0.focusHours }
        ),
        AchievementDefinition(
            code: "tasks_100",
            kind: .tasks,
            icon: "trophy.fill",
            title: "Чемпион",
            goal: "Выполни 100 заданий",
            targetValue: 100,
            sortOrder: 8,
            cellHeight: 170,
            progress: { $0.completedTasks }
        ),
        AchievementDefinition(
            code: "sleep_8h_14",
            kind: .sleep,
            icon: "moon.stars.fill",
            title: "Режим восстановлен",
            goal: "Спи не меньше 8 часов 14 дней",
            targetValue: 14,
            sortOrder: 9,
            cellHeight: 200,
            progress: { $0.eightHourSleepDays }
        ),
        AchievementDefinition(
            code: "emotion_high_10",
            kind: .emotion,
            icon: "face.smiling.fill",
            title: "Теплая полоса",
            goal: "Отметь эмоции интенсивностью 8+ в 10 дней",
            targetValue: 10,
            sortOrder: 10,
            cellHeight: 180,
            progress: { $0.highIntensityEmotionDays }
        ),
        AchievementDefinition(
            code: "focus_50",
            kind: .focus,
            icon: "crown.fill",
            title: "Мастер концентрации",
            goal: "Накопи 50 часов фокуса",
            targetValue: 50,
            sortOrder: 11,
            cellHeight: 200,
            progress: { $0.focusHours }
        )
    ]
}
