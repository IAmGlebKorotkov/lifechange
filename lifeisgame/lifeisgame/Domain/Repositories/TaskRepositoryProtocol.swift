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
        ownerId: UUID,
        parentTaskId: UUID?
    ) throws -> TaskItem

    func fetchTasks(forUserID id: UUID, on date: Date) throws -> [TaskItem]
    func toggleCompletion(taskID: UUID) throws
    func deleteTask(id: UUID) throws
}
