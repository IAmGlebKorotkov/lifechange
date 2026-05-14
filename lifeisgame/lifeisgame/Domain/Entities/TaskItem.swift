//
//  TaskItem.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.04.2026.
//

import Foundation

enum TaskSource: Equatable {
    case app
    case calendar
}

extension Notification.Name {
    static let taskStoreDidChange = Notification.Name("taskStoreDidChange")
}

struct TaskItem: Equatable {
    let id: UUID
    var name: String
    var taskDescription: String?
    var startDate: Date
    var deadlineDate: Date
    var isCompleted: Bool
    var isHardTask: Bool
    var planningStartDate: Date?
    var planningDeadlineDate: Date?
    var importance: Int
    var difficulty: Int
    var estimatedDuration: TimeInterval
    let createdAt: Date
    let ownerId: UUID
    let parentTaskId: UUID?
    var subtasks: [TaskItem]
    var source: TaskSource

    var isSubtask: Bool { parentTaskId != nil }
}
