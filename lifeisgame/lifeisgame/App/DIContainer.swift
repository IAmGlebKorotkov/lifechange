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
    private let diaryRepository: DiaryRepositoryProtocol
    private let calendarService: CalendarServiceProtocol

    init(userRepository: UserRepositoryProtocol = UserRepository(),
         taskRepository: TaskRepositoryProtocol = TaskRepository(),
         diaryRepository: DiaryRepositoryProtocol = DiaryRepository(),
         calendarService: CalendarServiceProtocol = CalendarEventService()) {
        self.userRepository = userRepository
        self.taskRepository = taskRepository
        self.diaryRepository = diaryRepository
        self.calendarService = calendarService
    }

    func makeLoginUseCase() -> LoginUseCase {
        LoginUseCase(repository: userRepository)
    }

    func makeRegisterUseCase() -> RegisterUseCase {
        RegisterUseCase(repository: userRepository)
    }

    func makeUserRepository() -> UserRepositoryProtocol {
        userRepository
    }

    func makeFetchTasksUseCase() -> FetchTasksUseCase {
        FetchTasksUseCase(repository: taskRepository, calendarService: calendarService)
    }

    func makeCreateTaskUseCase() -> CreateTaskUseCase {
        CreateTaskUseCase(repository: taskRepository, calendarService: calendarService)
    }

    func makeToggleTaskCompletionUseCase() -> ToggleTaskCompletionUseCase {
        ToggleTaskCompletionUseCase(repository: taskRepository)
    }

    func makeDiaryRepository() -> DiaryRepositoryProtocol {
        diaryRepository
    }
}
