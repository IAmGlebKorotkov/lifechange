//
//  CalendarViewModel.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.03.2026.
//

import Foundation

final class CalendarViewModel {

    private let fetchTasksUseCase: FetchTasksUseCase
    private let toggleUseCase: ToggleTaskCompletionUseCase

    var onAddTaskTapped: (() -> Void)?
    var onTasksUpdated: (([TaskItem]) -> Void)?

    private var selectedDate: Date = Date()

    init(fetchTasksUseCase: FetchTasksUseCase,
         toggleUseCase: ToggleTaskCompletionUseCase) {
        self.fetchTasksUseCase = fetchTasksUseCase
        self.toggleUseCase = toggleUseCase
    }

    func viewDidLoad() {
        loadTasks()
    }

    func dateSelected(_ date: Date) {
        selectedDate = date
        loadTasks()
    }

    func toggleTask(id: UUID) {
        try? toggleUseCase.execute(taskID: id)
        loadTasks()
    }

    private func loadTasks() {
        guard let userID = SessionManager.shared.currentUserID else {
            onTasksUpdated?([])
            return
        }
        fetchTasksUseCase.execute(userID: userID, date: selectedDate) { [weak self] tasks in
            self?.onTasksUpdated?(tasks)
        }
    }
}
