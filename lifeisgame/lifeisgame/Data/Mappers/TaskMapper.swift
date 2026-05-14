//
//  TaskMapper.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.04.2026.
//

import Foundation

enum TaskMapper {
    static func toDomain(_ entity: TaskEntity) -> TaskItem? {
        guard let id = entity.id,
              let name = entity.name,
              let startDate = entity.startDate,
              let deadlineDate = entity.deadlineDate,
              let createdAt = entity.createdAt,
              let ownerId = entity.owner?.id else { return nil }

        let subtasks = entity.subtasksArray.compactMap { toDomain($0) }

        return TaskItem(
            id: id,
            name: name,
            taskDescription: entity.taskDescription,
            startDate: startDate,
            deadlineDate: deadlineDate,
            isCompleted: entity.isCompleted,
            isHardTask: entity.isHardTask,
            planningStartDate: entity.planningStartDate,
            planningDeadlineDate: entity.planningDeadlineDate,
            importance: entity.importance == 0 ? 5 : Int(entity.importance),
            difficulty: entity.difficulty == 0 ? 5 : Int(entity.difficulty),
            estimatedDuration: entity.estimatedDuration == 0 ? deadlineDate.timeIntervalSince(startDate) : entity.estimatedDuration,
            createdAt: createdAt,
            ownerId: ownerId,
            parentTaskId: entity.parentTask?.id,
            subtasks: subtasks,
            source: .app
        )
    }
}
