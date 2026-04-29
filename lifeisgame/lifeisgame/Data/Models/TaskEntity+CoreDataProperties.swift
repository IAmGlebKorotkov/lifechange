//
//  TaskEntity+CoreDataProperties.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.04.2026.
//

import Foundation
import CoreData

extension TaskEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaskEntity> {
        NSFetchRequest<TaskEntity>(entityName: "TaskEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var taskDescription: String?
    @NSManaged public var startDate: Date?
    @NSManaged public var deadlineDate: Date?
    @NSManaged public var isCompleted: Bool
    @NSManaged public var isHardTask: Bool
    @NSManaged public var createdAt: Date?

    @NSManaged public var owner: UserEntity?
    @NSManaged public var parentTask: TaskEntity?
    @NSManaged public var subtasks: NSSet?

    var isSubtask: Bool { parentTask != nil }

    var subtasksArray: [TaskEntity] {
        (subtasks as? Set<TaskEntity>)?.sorted { ($0.createdAt ?? .distantPast) < ($1.createdAt ?? .distantPast) } ?? []
    }
}

extension TaskEntity {

    @objc(addSubtasksObject:)
    @NSManaged public func addToSubtasks(_ value: TaskEntity)

    @objc(removeSubtasksObject:)
    @NSManaged public func removeFromSubtasks(_ value: TaskEntity)

    @objc(addSubtasks:)
    @NSManaged public func addToSubtasks(_ values: NSSet)

    @objc(removeSubtasks:)
    @NSManaged public func removeFromSubtasks(_ values: NSSet)
}
