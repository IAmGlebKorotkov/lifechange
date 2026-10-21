//
//  AddTaskViewModel.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 20.06.2026.
//

import Foundation

enum AddTaskKind: CaseIterable, Equatable {
    case event
    case simpleTask
    case hardTask

    var title: String {
        switch self {
        case .event:
            return "Событие"
        case .simpleTask:
            return "Простая задача"
        case .hardTask:
            return "Сложная задача"
        }
    }

    var navigationTitle: String {
        switch self {
        case .event:
            return "Новое событие"
        case .simpleTask:
            return "Новая простая задача"
        case .hardTask:
            return "Новая сложная задача"
        }
    }

    var symbolName: String {
        switch self {
        case .event:
            return "calendar.badge.plus"
        case .simpleTask:
            return "checkmark.circle"
        case .hardTask:
            return "square.stack.3d.up"
        }
    }
}

struct AddTaskDraft {
    let name: String
    let description: String
    let startDate: Date
    let deadlineDate: Date
    let importance: Int
    let difficulty: Int
    let selectedDuration: TimeInterval
    let subtasks: [TaskService.SubtaskInput]
}

final class AddTaskViewModel {

    private let validator: TaskValidator
    let kind: AddTaskKind

    var isHardTask: Bool { kind == .hardTask }
    var isEvent: Bool { kind == .event }

    init(
        kind: AddTaskKind = .simpleTask,
        validator: TaskValidator = TaskValidator()
    ) {
        self.kind = kind
        self.validator = validator
    }

    func validate(_ draft: AddTaskDraft) -> TaskValidationResult {
        validator.validate(TaskValidationInput(
            name: draft.name,
            startDate: draft.startDate,
            deadlineDate: draft.deadlineDate,
            isHardTask: !isEvent && isHardTask,
            isEvent: isEvent,
            subtasksCount: (!isEvent && isHardTask) ? draft.subtasks.count : 0
        ))
    }

    func makeInput(from draft: AddTaskDraft) -> TaskService.Input {
        let description = draft.description.trimmingCharacters(in: .whitespacesAndNewlines)
        let eventDuration = max(15 * 60, draft.deadlineDate.timeIntervalSince(draft.startDate))

        return TaskService.Input(
            name: draft.name,
            description: description.isEmpty ? nil : description,
            startDate: draft.startDate,
            deadlineDate: draft.deadlineDate,
            importance: draft.importance,
            difficulty: draft.difficulty,
            estimatedDuration: isEvent ? eventDuration : draft.selectedDuration,
            isHardTask: !isEvent && isHardTask,
            isEvent: isEvent,
            subtasks: (!isEvent && isHardTask) ? draft.subtasks : []
        )
    }
}
