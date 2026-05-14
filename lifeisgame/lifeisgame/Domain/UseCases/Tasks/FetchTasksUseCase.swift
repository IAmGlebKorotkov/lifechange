//
//  FetchTasksUseCase.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.04.2026.
//

import Foundation

final class FetchTasksUseCase {

    private let repository: TaskRepositoryProtocol
    private let calendarService: CalendarServiceProtocol

    init(repository: TaskRepositoryProtocol, calendarService: CalendarServiceProtocol) {
        self.repository = repository
        self.calendarService = calendarService
    }

    func execute(userID: UUID, date: Date, completion: @escaping ([TaskItem]) -> Void) {
        let appTasks = (try? repository.fetchTasks(forUserID: userID, on: date)) ?? []

        calendarService.fetchEvents(for: date, userID: userID) { calendarTasks in
            let merged = (appTasks + calendarTasks).sorted { Self.sortDate(for: $0) < Self.sortDate(for: $1) }
            DispatchQueue.main.async {
                completion(merged)
            }
        }
    }

    private static func sortDate(for task: TaskItem) -> Date {
        if task.isHardTask, let firstSubtaskDate = task.subtasks.map(\.startDate).min() {
            return firstSubtaskDate
        }
        return task.startDate
    }
}
