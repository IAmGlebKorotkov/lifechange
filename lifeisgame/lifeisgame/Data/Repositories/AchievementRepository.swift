//
//  AchievementRepository.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 12.05.2026.
//

import Foundation
import CoreData

final class AchievementRepository: AchievementRepositoryProtocol {

    private let persistence: PersistenceController
    private let calendar: Calendar
    private let achievementCatalog: AchievementCatalogProviding

    init(persistence: PersistenceController = .shared,
         calendar: Calendar = .current,
         achievementCatalog: AchievementCatalogProviding = DefaultAchievementCatalog()) {
        self.persistence = persistence
        self.calendar = calendar
        self.achievementCatalog = achievementCatalog
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

        for definition in achievementCatalog.definitions {
            let entity = existingByCode[definition.code] ?? AchievementEntity(context: persistence.context)
            if entity.id == nil {
                entity.id = UUID()
                entity.createdAt = Date()
                entity.currentValue = 0
                entity.state = AchievementState.locked.rawValue
                entity.owner = owner
            }

            // Записываем только реальные изменения: иначе каждый fetch
            // помечает контекст «грязным» и провоцирует лишний save.
            setIfChanged(entity, \.code, definition.code)
            setIfChanged(entity, \.kind, definition.kind.rawValue)
            setIfChanged(entity, \.icon, definition.icon)
            setIfChanged(entity, \.title, definition.title)
            setIfChanged(entity, \.goal, definition.goal)
            if entity.targetValue != Int32(definition.targetValue) {
                entity.targetValue = Int32(definition.targetValue)
            }
            if entity.cellHeight != definition.cellHeight {
                entity.cellHeight = definition.cellHeight
            }
            if entity.sortOrder != Int16(definition.sortOrder) {
                entity.sortOrder = Int16(definition.sortOrder)
            }
        }
    }

    private func setIfChanged(
        _ entity: AchievementEntity,
        _ keyPath: ReferenceWritableKeyPath<AchievementEntity, String?>,
        _ value: String
    ) {
        if entity[keyPath: keyPath] != value {
            entity[keyPath: keyPath] = value
        }
    }

    private func refreshProgress(for owner: UserEntity, userID: UUID) throws {
        let metrics = try achievementMetrics(forUserID: userID)
        let entitiesByCode = achievementsByCode(owner.achievementsArray)

        for definition in achievementCatalog.definitions {
            guard let entity = entitiesByCode[definition.code] else { continue }
            let currentValue = max(0, definition.progress(metrics))
            if entity.currentValue != Int32(currentValue) {
                entity.currentValue = Int32(currentValue)
            }

            let existingState = AchievementState(rawValue: entity.state ?? "") ?? .locked
            let newState: AchievementState
            if entity.openedAt != nil || existingState == .opened {
                newState = .opened
            } else if entity.unlockedAt != nil || currentValue >= definition.targetValue {
                if entity.unlockedAt == nil {
                    entity.unlockedAt = Date()
                }
                newState = .unlocked
            } else {
                newState = .locked
            }

            if existingState != newState {
                entity.state = newState.rawValue
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
