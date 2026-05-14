//
//  CalendarViewModel.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.03.2026.
//

import Foundation
import EventKit
import UIKit

final class CalendarViewModel {

    private let fetchTasksUseCase: FetchTasksUseCase
    private let toggleUseCase: ToggleTaskCompletionUseCase

    var onAddTaskTapped: ((Date) -> Void)?
    var onTasksUpdated: (([TaskItem]) -> Void)?

    private var selectedDate: Date = Date()
    private var selectedFilter: CalendarFilter = .all
    private var reloadWorkItem: DispatchWorkItem?

    init(fetchTasksUseCase: FetchTasksUseCase,
         toggleUseCase: ToggleTaskCompletionUseCase) {
        self.fetchTasksUseCase = fetchTasksUseCase
        self.toggleUseCase = toggleUseCase
        observeTaskChanges()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func viewDidLoad() {
        loadTasks()
    }

    func refresh() {
        loadTasks()
    }

    func dateSelected(_ date: Date) {
        selectedDate = date
        loadTasks()
    }

    func filterSelected(_ filter: CalendarFilter) {
        selectedFilter = filter
        loadTasks()
    }

    func addTaskTapped() {
        onAddTaskTapped?(selectedDate)
    }

    func toggleTask(id: UUID) {
        try? toggleUseCase.execute(taskID: id)
        loadTasks()
    }

    private func observeTaskChanges() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(tasksDidChange),
            name: .taskStoreDidChange,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(tasksDidChange),
            name: .EKEventStoreChanged,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(tasksDidChange),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    @objc private func tasksDidChange() {
        scheduleReload()
    }

    private func scheduleReload() {
        reloadWorkItem?.cancel()
        let workItem = DispatchWorkItem { [weak self] in
            self?.loadTasks()
        }
        reloadWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: workItem)
    }

    private func loadTasks() {
        guard let userID = SessionManager.shared.currentUserID else {
            onTasksUpdated?([])
            return
        }
        fetchTasksUseCase.execute(userID: userID, date: selectedDate) { [weak self] tasks in
            guard let self else { return }
            self.onTasksUpdated?(self.filter(tasks))
        }
    }

    private func filter(_ tasks: [TaskItem]) -> [TaskItem] {
        switch selectedFilter {
        case .all:
            return tasks
        case .inProgress:
            return tasks.compactMap { filteredTask($0, isCompleted: false) }
        case .done:
            return tasks.compactMap { filteredTask($0, isCompleted: true) }
        }
    }

    private func filteredTask(_ task: TaskItem, isCompleted: Bool) -> TaskItem? {
        if task.isHardTask && !task.subtasks.isEmpty {
            var filtered = task
            filtered.subtasks = task.subtasks.filter { $0.isCompleted == isCompleted }
            return filtered.subtasks.isEmpty ? nil : filtered
        }

        return task.isCompleted == isCompleted ? task : nil
    }
}
