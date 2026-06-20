//
//  AddSubtaskViewModel.swift
//  lifeisgame
//
//  Created by Codex on 20.06.2026.
//

import Foundation

enum AddSubtaskMode {
    case add
    case edit(currentSubtask: TaskService.SubtaskInput, onSaved: (TaskService.SubtaskInput) -> Void)
}

final class AddSubtaskViewModel {

    let parentTaskName: String

    private let mode: AddSubtaskMode
    private let validator: SubtaskValidator

    init(
        parentTaskName: String,
        mode: AddSubtaskMode = .add,
        validator: SubtaskValidator = SubtaskValidator()
    ) {
        self.parentTaskName = parentTaskName
        self.mode = mode
        self.validator = validator
    }

    var title: String {
        switch mode {
        case .add:
            return "Добавить подзадачу"
        case .edit:
            return "Изменение подзадачи"
        }
    }

    var currentSubtask: TaskService.SubtaskInput? {
        guard case .edit(let currentSubtask, _) = mode else { return nil }
        return currentSubtask
    }

    var showsAddMoreButton: Bool {
        if case .edit = mode {
            return false
        }
        return true
    }

    var isEditingExistingSubtask: Bool {
        if case .edit = mode {
            return true
        }
        return false
    }

    func canSave(name: String?) -> Bool {
        validator.isValid(SubtaskValidationInput(name: name ?? ""))
    }

    func makeInput(
        name rawName: String?,
        description rawDescription: String,
        importance: Int,
        difficulty: Int,
        estimatedDuration: TimeInterval
    ) -> TaskService.SubtaskInput? {
        let name = rawName?.trimmingCharacters(in: .whitespaces) ?? ""
        guard !name.isEmpty else { return nil }

        let description = rawDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        return TaskService.SubtaskInput(
            name: name,
            description: description.isEmpty ? nil : description,
            importance: importance,
            difficulty: difficulty,
            estimatedDuration: estimatedDuration
        )
    }

    func saveEditedSubtask(_ subtask: TaskService.SubtaskInput) {
        guard case .edit(_, let onSaved) = mode else { return }
        onSaved(subtask)
    }
}
