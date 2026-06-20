//
//  AddTaskFlowViewModel.swift
//  lifeisgame
//
//  Created by Codex on 20.06.2026.
//

import Foundation

enum AddTaskCreationOutput {
    case event(TaskItem)
    case task(TaskItem, lateBoundary: Date?)
}

enum AddTaskFlowError: LocalizedError {
    case missingUser

    var errorDescription: String? {
        switch self {
        case .missingUser:
            return "Не удалось найти активную сессию"
        }
    }
}

final class AddTaskFlowViewModel {

    private let taskService: TaskService
    private let notificationService: LocalNotificationService

    init(
        taskService: TaskService,
        notificationService: LocalNotificationService = .shared
    ) {
        self.taskService = taskService
        self.notificationService = notificationService
    }

    func createTask(
        input: TaskService.Input,
        completion: @escaping (Result<AddTaskCreationOutput, Error>) -> Void
    ) {
        guard let userID = SessionManager.shared.currentUserID else {
            completion(.failure(AddTaskFlowError.missingUser))
            return
        }

        taskService.createTask(input: input, userID: userID) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let task):
                if input.isEvent {
                    completion(.success(.event(task)))
                } else {
                    completion(.success(.task(task, lateBoundary: self.taskService.lateBoundary(for: task))))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func splitTaskAtLateBoundary(_ task: TaskItem) -> [TaskItem] {
        guard let userID = SessionManager.shared.currentUserID else { return [task] }
        return (try? taskService.splitTaskAtLateBoundary(task, userID: userID)) ?? [task]
    }

    func scheduleReminders(for tasks: [TaskItem]) {
        notificationService.scheduleTaskReminders(for: tasks)
    }
}
