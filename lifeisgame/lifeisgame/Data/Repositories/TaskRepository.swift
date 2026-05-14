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
                    isHardTask: Bool, planningStartDate: Date?, planningDeadlineDate: Date?,
                    importance: Int, difficulty: Int, estimatedDuration: TimeInterval,
                    ownerId: UUID, parentTaskId: UUID?) throws -> TaskItem {
        let ctx = persistence.context
        let entity = TaskEntity(context: ctx)
        entity.id = UUID()
        entity.name = name
        entity.taskDescription = description
        entity.startDate = startDate
        entity.deadlineDate = deadlineDate
        entity.isHardTask = isHardTask
        entity.planningStartDate = planningStartDate
        entity.planningDeadlineDate = planningDeadlineDate
        entity.importance = Int16(max(1, min(10, importance)))
        entity.difficulty = Int16(max(1, min(10, difficulty)))
        entity.estimatedDuration = estimatedDuration
        entity.isCompleted = false
        entity.createdAt = Date()
        entity.owner = try fetchUserEntity(id: ownerId)
        if let parentID = parentTaskId {
            entity.parentTask = try fetchTaskEntity(id: parentID)
        }
        persistence.save()
        NotificationCenter.default.post(name: .taskStoreDidChange, object: nil)
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
            format: "owner.id == %@ AND parentTask == nil AND startDate < %@ AND deadlineDate > %@",
            id as CVarArg, end as NSDate, start as NSDate
        )
        request.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: true)]
        return try persistence.context.fetch(request)
            .compactMap { TaskMapper.toDomain($0) }
            .compactMap { taskForDay($0, start: start, end: end) }
            .sorted { sortDate(for: $0) < sortDate(for: $1) }
    }

    func fetchTasks(forUserID id: UUID, from startDate: Date, to endDate: Date) throws -> [TaskItem] {
        let request = TaskEntity.fetchRequest()
        request.predicate = NSPredicate(
            format: "owner.id == %@ AND parentTask == nil AND startDate < %@ AND deadlineDate > %@",
            id as CVarArg, endDate as NSDate, startDate as NSDate
        )
        request.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: true)]
        return try persistence.context.fetch(request).compactMap { TaskMapper.toDomain($0) }
    }

    func updateTaskSchedule(taskID: UUID, startDate: Date, deadlineDate: Date, estimatedDuration: TimeInterval) throws -> TaskItem {
        guard let entity = try fetchTaskEntity(id: taskID) else {
            throw RepositoryError.notFound
        }
        entity.startDate = startDate
        entity.deadlineDate = deadlineDate
        entity.estimatedDuration = estimatedDuration
        for subtask in entity.subtasksArray {
            subtask.startDate = startDate
            subtask.deadlineDate = deadlineDate
            subtask.estimatedDuration = estimatedDuration
        }
        persistence.save()
        NotificationCenter.default.post(name: .taskStoreDidChange, object: nil)
        guard let item = TaskMapper.toDomain(entity) else {
            throw RepositoryError.mappingFailed
        }
        return item
    }

    func toggleCompletion(taskID: UUID) throws {
        guard let entity = try fetchTaskEntity(id: taskID) else { return }
        entity.isCompleted = !entity.isCompleted
        persistence.save()
        NotificationCenter.default.post(name: .taskStoreDidChange, object: nil)
    }

    func deleteTask(id: UUID) throws {
        guard let entity = try fetchTaskEntity(id: id) else { return }
        persistence.context.delete(entity)
        persistence.save()
        NotificationCenter.default.post(name: .taskStoreDidChange, object: nil)
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

    private func taskForDay(_ task: TaskItem, start: Date, end: Date) -> TaskItem? {
        guard task.startDate < end, task.deadlineDate > start else { return nil }
        guard task.isHardTask && !task.subtasks.isEmpty else { return task }

        var filtered = task
        filtered.subtasks = task.subtasks
            .filter { $0.startDate < end && $0.deadlineDate > start }
            .sorted { $0.startDate < $1.startDate }
        return filtered.subtasks.isEmpty ? nil : filtered
    }

    private func sortDate(for task: TaskItem) -> Date {
        if task.isHardTask, let firstSubtaskDate = task.subtasks.map(\.startDate).min() {
            return firstSubtaskDate
        }
        return task.startDate
    }
}
