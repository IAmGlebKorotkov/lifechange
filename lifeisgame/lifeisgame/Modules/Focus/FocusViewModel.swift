//
//  FocusViewModel.swift
//  lifeisgame
//
//  Created by Codex on 14.05.2026.
//

import Foundation

struct FocusTaskItem {
    let mainTaskName: String?
    let typeTitle: String
    let title: String
    let startDate: Date
    let deadlineDate: Date
    let importance: Int
}

final class FocusViewModel {

    var onTasksUpdated: (([FocusTaskItem]) -> Void)?

    private let fetchTasksUseCase: FetchTasksUseCase
    private let date: Date

    init(fetchTasksUseCase: FetchTasksUseCase, date: Date = Date()) {
        self.fetchTasksUseCase = fetchTasksUseCase
        self.date = date
    }

    func viewDidLoad() {
        loadTasks()
    }

    func refresh() {
        loadTasks()
    }

    private func loadTasks() {
        guard let userID = SessionManager.shared.currentUserID else {
            onTasksUpdated?([])
            return
        }

        fetchTasksUseCase.execute(userID: userID, date: date) { [weak self] tasks in
            self?.onTasksUpdated?(Self.incompleteFocusTasks(from: tasks))
        }
    }

    private static func incompleteFocusTasks(from tasks: [TaskItem]) -> [FocusTaskItem] {
        tasks.flatMap { task -> [FocusTaskItem] in
            if task.isHardTask && !task.subtasks.isEmpty {
                return task.subtasks
                    .filter { !$0.isCompleted }
                    .map {
                        FocusTaskItem(
                            mainTaskName: task.name,
                            typeTitle: "Подзадача",
                            title: $0.name,
                            startDate: $0.startDate,
                            deadlineDate: $0.deadlineDate,
                            importance: $0.importance
                        )
                    }
            }

            guard !task.isCompleted else { return [] }
            let typeTitle = task.source == .calendar ? "Событие" : (task.isHardTask ? "Сложная задача" : "Задача")
            return [
                FocusTaskItem(
                    mainTaskName: nil,
                    typeTitle: typeTitle,
                    title: task.name,
                    startDate: task.startDate,
                    deadlineDate: task.deadlineDate,
                    importance: task.importance
                )
            ]
        }
    }
}
