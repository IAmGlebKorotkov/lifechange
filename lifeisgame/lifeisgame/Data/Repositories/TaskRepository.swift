//
//  TaskRepository.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.04.2026.
//

import Foundation
import CoreData

final class TaskRepository: TaskRepositoryProtocol {

    private let persistence: PersistenceController

    init(persistence: PersistenceController = .shared) {
        self.persistence = persistence
    }

    func createTask(name: String, description: String?, startDate: Date, deadlineDate: Date,
                    isHardTask: Bool, ownerId: UUID, parentTaskId: UUID?) throws -> TaskItem {
        let ctx = persistence.context
        let entity = TaskEntity(context: ctx)
        entity.id = UUID()
        entity.name = name
        entity.taskDescription = description
        entity.startDate = startDate
        entity.deadlineDate = deadlineDate
        entity.isHardTask = isHardTask
        entity.isCompleted = false
        entity.createdAt = Date()
        entity.owner = try fetchUserEntity(id: ownerId)
        if let parentID = parentTaskId {
            entity.parentTask = try fetchTaskEntity(id: parentID)
        }
        persistence.save()
        guard let item = TaskMapper.toDomain(entity) else {
            throw RepositoryError.mappingFailed
        }
        return item
    }

    func fetchTasks(forUserID id: UUID, on date: Date) throws -> [TaskItem] {
        let cal = Calendar.current
        let start = cal.startOfDay(for: date)
        let end = cal.date(byAdding: .day, value: 1, to: start)!

        let request = TaskEntity.fetchRequest()
        request.predicate = NSPredicate(
            format: "owner.id == %@ AND parentTask == nil AND startDate >= %@ AND startDate < %@",
            id as CVarArg, start as NSDate, end as NSDate
        )
        request.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: true)]
        return try persistence.context.fetch(request).compactMap { TaskMapper.toDomain($0) }
    }

    func toggleCompletion(taskID: UUID) throws {
        guard let entity = try fetchTaskEntity(id: taskID) else { return }
        entity.isCompleted = !entity.isCompleted
        persistence.save()
    }

    func deleteTask(id: UUID) throws {
        guard let entity = try fetchTaskEntity(id: id) else { return }
        persistence.context.delete(entity)
        persistence.save()
    }

    private func fetchUserEntity(id: UUID) throws -> UserEntity? {
        let request = UserEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        return try persistence.context.fetch(request).first
    }

    private func fetchTaskEntity(id: UUID) throws -> TaskEntity? {
        let request = TaskEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        return try persistence.context.fetch(request).first
    }
}
