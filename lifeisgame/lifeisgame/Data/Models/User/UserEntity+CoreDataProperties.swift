//
//  UserEntity+CoreDataProperties.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.04.2026.
//

import Foundation
import CoreData

extension UserEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserEntity> {
        NSFetchRequest<UserEntity>(entityName: "UserEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var email: String?
    @NSManaged public var birthDate: Date?
    @NSManaged public var createdAt: Date?
    @NSManaged public var tasks: NSSet?
    @NSManaged public var emotionEntries: NSSet?
    @NSManaged public var sleepEntries: NSSet?
    @NSManaged public var achievements: NSSet?
    @NSManaged public var focusSessions: NSSet?

    var tasksArray: [TaskEntity] {
        (tasks as? Set<TaskEntity>)?.sorted { ($0.createdAt ?? .distantPast) < ($1.createdAt ?? .distantPast) } ?? []
    }

    var rootTasks: [TaskEntity] {
        tasksArray.filter { $0.parentTask == nil }
    }

    var emotionEntriesArray: [EmotionEntryEntity] {
        (emotionEntries as? Set<EmotionEntryEntity>)?.sorted { ($0.createdAt ?? .distantPast) < ($1.createdAt ?? .distantPast) } ?? []
    }

    var sleepEntriesArray: [SleepEntryEntity] {
        (sleepEntries as? Set<SleepEntryEntity>)?.sorted { ($0.dayDate ?? .distantPast) < ($1.dayDate ?? .distantPast) } ?? []
    }

    var achievementsArray: [AchievementEntity] {
        (achievements as? Set<AchievementEntity>)?.sorted { $0.sortOrder < $1.sortOrder } ?? []
    }

    var focusSessionsArray: [FocusSessionEntity] {
        (focusSessions as? Set<FocusSessionEntity>)?.sorted { ($0.startedAt ?? .distantPast) < ($1.startedAt ?? .distantPast) } ?? []
    }
}

extension UserEntity {

    @objc(addTasksObject:)
    @NSManaged public func addToTasks(_ value: TaskEntity)

    @objc(removeTasksObject:)
    @NSManaged public func removeFromTasks(_ value: TaskEntity)

    @objc(addTasks:)
    @NSManaged public func addToTasks(_ values: NSSet)

    @objc(removeTasks:)
    @NSManaged public func removeFromTasks(_ values: NSSet)
}

extension UserEntity {

    @objc(addEmotionEntriesObject:)
    @NSManaged public func addToEmotionEntries(_ value: EmotionEntryEntity)

    @objc(removeEmotionEntriesObject:)
    @NSManaged public func removeFromEmotionEntries(_ value: EmotionEntryEntity)

    @objc(addEmotionEntries:)
    @NSManaged public func addToEmotionEntries(_ values: NSSet)

    @objc(removeEmotionEntries:)
    @NSManaged public func removeFromEmotionEntries(_ values: NSSet)
}

extension UserEntity {

    @objc(addSleepEntriesObject:)
    @NSManaged public func addToSleepEntries(_ value: SleepEntryEntity)

    @objc(removeSleepEntriesObject:)
    @NSManaged public func removeFromSleepEntries(_ value: SleepEntryEntity)

    @objc(addSleepEntries:)
    @NSManaged public func addToSleepEntries(_ values: NSSet)

    @objc(removeSleepEntries:)
    @NSManaged public func removeFromSleepEntries(_ values: NSSet)
}

extension UserEntity {

    @objc(addAchievementsObject:)
    @NSManaged public func addToAchievements(_ value: AchievementEntity)

    @objc(removeAchievementsObject:)
    @NSManaged public func removeFromAchievements(_ value: AchievementEntity)

    @objc(addAchievements:)
    @NSManaged public func addToAchievements(_ values: NSSet)

    @objc(removeAchievements:)
    @NSManaged public func removeFromAchievements(_ values: NSSet)
}

extension UserEntity {

    @objc(addFocusSessionsObject:)
    @NSManaged public func addToFocusSessions(_ value: FocusSessionEntity)

    @objc(removeFocusSessionsObject:)
    @NSManaged public func removeFromFocusSessions(_ value: FocusSessionEntity)

    @objc(addFocusSessions:)
    @NSManaged public func addToFocusSessions(_ values: NSSet)

    @objc(removeFocusSessions:)
    @NSManaged public func removeFromFocusSessions(_ values: NSSet)
}
