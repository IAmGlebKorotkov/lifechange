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

    var tasksArray: [TaskEntity] {
        (tasks as? Set<TaskEntity>)?.sorted { ($0.createdAt ?? .distantPast) < ($1.createdAt ?? .distantPast) } ?? []
    }

    var rootTasks: [TaskEntity] {
        tasksArray.filter { $0.parentTask == nil }
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
