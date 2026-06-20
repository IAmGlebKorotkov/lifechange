//
//  EditTaskViewModel.swift
//  lifeisgame
//
//  Created by Codex on 20.06.2026.
//

import Foundation

struct EditTaskViewData {
    let name: String
    let description: String?
    let importance: Int
    let difficulty: Int
    let timeRangeText: String
    let durationText: String
}

final class EditTaskViewModel {

    var onSaved: (() -> Void)?
    var onSaveFailed: ((String) -> Void)?

    private let task: TaskItem
    private let taskService: TaskService

    init(task: TaskItem, taskService: TaskService) {
        self.task = task
        self.taskService = taskService
    }

    var viewData: EditTaskViewData {
        EditTaskViewData(
            name: task.name,
            description: task.taskDescription,
            importance: task.importance,
            difficulty: task.difficulty,
            timeRangeText: "\(DateFormatter.appDateTimeString(from: task.startDate)) - \(DateFormatter.appDateTimeString(from: task.deadlineDate))",
            durationText: durationString(task.estimatedDuration)
        )
    }

    func canSaveTaskName(_ name: String?) -> Bool {
        !(name ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func save(
        name rawName: String?,
        description rawDescription: String,
        importance: Int,
        difficulty: Int
    ) {
        let name = (rawName ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else {
            onSaveFailed?("Введите название задачи")
            return
        }

        let description = rawDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        let input = TaskService.UpdateInput(
            taskID: task.id,
            name: name,
            description: description.isEmpty ? nil : description,
            importance: importance,
            difficulty: difficulty
        )

        do {
            _ = try taskService.updateTaskDetails(input: input)
            onSaved?()
        } catch {
            onSaveFailed?(error.localizedDescription)
        }
    }

    private func durationString(_ duration: TimeInterval) -> String {
        let minutes = max(0, Int(duration / 60))
        if minutes < 60 { return "\(minutes) мин" }
        let hours = minutes / 60
        let restMinutes = minutes % 60
        return restMinutes == 0 ? "\(hours) ч" : "\(hours) ч \(restMinutes) мин"
    }
}
