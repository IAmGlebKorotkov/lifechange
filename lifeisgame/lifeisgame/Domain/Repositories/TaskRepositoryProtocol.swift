//
//  TaskRepositoryProtocol.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.04.2026.
//

import Foundation

protocol TaskRepositoryProtocol {
    func createTask(
        name: String,
        description: String?,
        startDate: Date,
        deadlineDate: Date,
        isHardTask: Bool,
        planningStartDate: Date?,
        planningDeadlineDate: Date?,
        importance: Int,
        difficulty: Int,
        estimatedDuration: TimeInterval,
        ownerId: UUID,
        parentTaskId: UUID?
    ) throws -> TaskItem

    func fetchTasks(forUserID id: UUID, on date: Date) throws -> [TaskItem]
    func fetchTasks(forUserID id: UUID, from startDate: Date, to endDate: Date) throws -> [TaskItem]
    func updateTaskSchedule(taskID: UUID, startDate: Date, deadlineDate: Date, estimatedDuration: TimeInterval) throws -> TaskItem
    func updateTaskDetails(taskID: UUID, name: String, description: String?, importance: Int, difficulty: Int) throws -> TaskItem
    func toggleCompletion(taskID: UUID) throws
    func deleteTask(id: UUID) throws
}
