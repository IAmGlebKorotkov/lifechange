//
//  TaskValidationUseCase.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 09.04.2026.
//

import Foundation


struct TaskValidationInput {
    let name: String
    let startDate: Date
    let deadlineDate: Date
    let isHardTask: Bool
    let subtasksCount: Int
}


enum TaskValidationError: Equatable {
    case emptyName
    case deadlineBeforeStart
    case noSubtasks

    var message: String {
        switch self {
        case .emptyName:          return "Введите название задачи"
        case .deadlineBeforeStart: return "Дедлайн должен быть позже даты начала"
        case .noSubtasks:         return "Добавьте хотя бы одну подзадачу"
        }
    }
}


struct TaskValidationResult {
    let isValid: Bool
    let errors: [TaskValidationError]
}


struct TaskValidationUseCase {

    func validate(_ input: TaskValidationInput) -> TaskValidationResult {
        var errors: [TaskValidationError] = []

        if input.name.trimmingCharacters(in: .whitespaces).isEmpty {
            errors.append(.emptyName)
        }

        if Calendar.current.startOfDay(for: input.deadlineDate)
            < Calendar.current.startOfDay(for: input.startDate) {
            errors.append(.deadlineBeforeStart)
        }

        if input.isHardTask && input.subtasksCount == 0 {
            errors.append(.noSubtasks)
        }

        return TaskValidationResult(isValid: errors.isEmpty, errors: errors)
    }
}
