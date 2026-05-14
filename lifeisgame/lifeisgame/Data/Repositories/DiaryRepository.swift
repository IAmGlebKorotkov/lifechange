//
//  DiaryRepository.swift
//  lifeisgame
//
//  Created by Codex on 08.05.2026.
//

import Foundation
import CoreData

final class DiaryRepository: DiaryRepositoryProtocol {

    private let persistence: PersistenceController
    private let calendar: Calendar

    init(persistence: PersistenceController = .shared,
         calendar: Calendar = .current) {
        self.persistence = persistence
        self.calendar = calendar
    }

    func saveEmotionEntries(_ entries: [EmotionDiaryInput], forUserID userID: UUID, on date: Date) throws -> [EmotionDiaryEntry] {
        guard !entries.isEmpty else { return [] }
        guard let owner = try fetchUserEntity(id: userID) else {
            throw RepositoryError.notFound
        }

        let ctx = persistence.context
        let dayDate = calendar.startOfDay(for: date)
        let now = Date()
        let createdEntities = entries.map { input in
            let entity = EmotionEntryEntity(context: ctx)
            entity.id = UUID()
            entity.emotionName = input.emotionName
            entity.sfSymbol = input.sfSymbol
            entity.reason = normalizedReason(input.reason)
            entity.intensity = Int16(max(1, min(10, input.intensity)))
            entity.dayDate = dayDate
            entity.createdAt = now
            entity.owner = owner
            return entity
        }

        persistence.save()
        NotificationCenter.default.post(name: .diaryStoreDidChange, object: nil)
        return createdEntities.compactMap { DiaryMapper.emotionToDomain($0) }
    }

    func saveSleepEntry(bedtime: Date, wakeTime: Date, forUserID userID: UUID, on date: Date) throws -> SleepDiaryEntry {
        guard let owner = try fetchUserEntity(id: userID) else {
            throw RepositoryError.notFound
        }

        let dayDate = calendar.startOfDay(for: date)
        let normalizedBedtime = time(from: bedtime, on: dayDate)
        var normalizedWakeTime = time(from: wakeTime, on: dayDate)
        if normalizedWakeTime <= normalizedBedtime,
           let nextDayWakeTime = calendar.date(byAdding: .day, value: 1, to: normalizedWakeTime) {
            normalizedWakeTime = nextDayWakeTime
        }

        let durationMinutes = max(0, Int(normalizedWakeTime.timeIntervalSince(normalizedBedtime) / 60))
        let entity = try fetchSleepEntity(forUserID: userID, on: dayDate) ?? SleepEntryEntity(context: persistence.context)
        if entity.id == nil {
            entity.id = UUID()
            entity.createdAt = Date()
        }

        entity.dayDate = dayDate
        entity.bedtime = normalizedBedtime
        entity.wakeTime = normalizedWakeTime
        entity.durationMinutes = Int32(durationMinutes)
        entity.owner = owner

        persistence.save()
        NotificationCenter.default.post(name: .diaryStoreDidChange, object: nil)

        guard let entry = DiaryMapper.sleepToDomain(entity) else {
            throw RepositoryError.mappingFailed
        }
        return entry
    }

    func fetchEmotionEntries(forUserID userID: UUID) throws -> [EmotionDiaryEntry] {
        let request = EmotionEntryEntity.fetchRequest()
        request.predicate = NSPredicate(format: "owner.id == %@", userID as CVarArg)
        request.sortDescriptors = [
            NSSortDescriptor(key: "dayDate", ascending: false),
            NSSortDescriptor(key: "createdAt", ascending: false)
        ]
        return try persistence.context.fetch(request).compactMap { DiaryMapper.emotionToDomain($0) }
    }

    func fetchSleepEntries(forUserID userID: UUID) throws -> [SleepDiaryEntry] {
        let request = SleepEntryEntity.fetchRequest()
        request.predicate = NSPredicate(format: "owner.id == %@", userID as CVarArg)
        request.sortDescriptors = [
            NSSortDescriptor(key: "dayDate", ascending: false),
            NSSortDescriptor(key: "createdAt", ascending: false)
        ]
        return try persistence.context.fetch(request).compactMap { DiaryMapper.sleepToDomain($0) }
    }

    func hasEmotionEntry(forUserID userID: UUID, on date: Date) throws -> Bool {
        let request = EmotionEntryEntity.fetchRequest()
        request.predicate = NSPredicate(
            format: "owner.id == %@ AND dayDate == %@",
            userID as CVarArg,
            calendar.startOfDay(for: date) as NSDate
        )
        request.fetchLimit = 1
        return try persistence.context.count(for: request) > 0
    }

    func hasSleepEntry(forUserID userID: UUID, on date: Date) throws -> Bool {
        try fetchSleepEntity(forUserID: userID, on: calendar.startOfDay(for: date)) != nil
    }

    private func fetchUserEntity(id: UUID) throws -> UserEntity? {
        let request = UserEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        return try persistence.context.fetch(request).first
    }

    private func fetchSleepEntity(forUserID userID: UUID, on dayDate: Date) throws -> SleepEntryEntity? {
        let request = SleepEntryEntity.fetchRequest()
        request.predicate = NSPredicate(
            format: "owner.id == %@ AND dayDate == %@",
            userID as CVarArg,
            dayDate as NSDate
        )
        request.fetchLimit = 1
        return try persistence.context.fetch(request).first
    }

    private func time(from date: Date, on dayDate: Date) -> Date {
        let components = calendar.dateComponents([.hour, .minute], from: date)
        return calendar.date(
            bySettingHour: components.hour ?? 0,
            minute: components.minute ?? 0,
            second: 0,
            of: dayDate
        ) ?? dayDate
    }

    private func normalizedReason(_ reason: String?) -> String? {
        let trimmed = reason?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return trimmed.isEmpty ? nil : trimmed
    }
}
