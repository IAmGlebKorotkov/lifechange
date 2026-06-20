//
//  AddTaskViewModel.swift
//  lifeisgame
//
//  Created by Codex on 20.06.2026.
//

import Foundation

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

    private(set) var isHardTask = false
    private(set) var isEvent = false

    init(validator: TaskValidator = TaskValidator()) {
        self.validator = validator
    }

    func setEvent(_ isEvent: Bool) {
        self.isEvent = isEvent
    }

    func setHardTask(_ isHardTask: Bool) {
        self.isHardTask = isHardTask
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
