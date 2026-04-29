//
//  DIContainer.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.04.2026.
//

import Foundation

final class DIContainer {

    private let userRepository: UserRepositoryProtocol
    private let taskRepository: TaskRepositoryProtocol
    private let calendarService: CalendarServiceProtocol

    init(userRepository: UserRepositoryProtocol = UserRepository(),
         taskRepository: TaskRepositoryProtocol = TaskRepository(),
         calendarService: CalendarServiceProtocol = CalendarEventService()) {
        self.userRepository = userRepository
        self.taskRepository = taskRepository
        self.calendarService = calendarService
    }

    func makeLoginUseCase() -> LoginUseCase {
        LoginUseCase(repository: userRepository)
    }

    func makeRegisterUseCase() -> RegisterUseCase {
        RegisterUseCase(repository: userRepository)
    }

    func makeFetchTasksUseCase() -> FetchTasksUseCase {
        FetchTasksUseCase(repository: taskRepository, calendarService: calendarService)
    }

    func makeCreateTaskUseCase() -> CreateTaskUseCase {
        CreateTaskUseCase(repository: taskRepository)
    }

    func makeToggleTaskCompletionUseCase() -> ToggleTaskCompletionUseCase {
        ToggleTaskCompletionUseCase(repository: taskRepository)
    }
}
