//
//  TaskService.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 19.06.2026.
//

import Foundation

final class TaskService {

    struct SubtaskInput {
        let name: String
        let description: String?
        let importance: Int
        let difficulty: Int
        let estimatedDuration: TimeInterval
    }

    struct Input {
        let name: String
        let description: String?
        let startDate: Date
        let deadlineDate: Date
        let importance: Int
        let difficulty: Int
        let estimatedDuration: TimeInterval
        let isHardTask: Bool
        let isEvent: Bool
        let subtasks: [SubtaskInput]
    }

    struct UpdateInput {
        let taskID: UUID
        let name: String
        let description: String?
        let importance: Int
        let difficulty: Int
    }

    private let repository: TaskRepositoryProtocol
    private let calendarService: CalendarServiceProtocol

    init(
        repository: TaskRepositoryProtocol = TaskRepository(),
        calendarService: CalendarServiceProtocol = CalendarEventService()
    ) {
        self.repository = repository
        self.calendarService = calendarService
    }

    func fetchTasks(userID: UUID, date: Date, completion: @escaping ([TaskItem]) -> Void) {
        let appTasks = (try? repository.fetchTasks(forUserID: userID, on: date)) ?? []

        calendarService.fetchEvents(for: date, userID: userID) { calendarTasks in
            let merged = (appTasks + calendarTasks).sorted { Self.sortDate(for: $0) < Self.sortDate(for: $1) }
            DispatchQueue.main.async {
                completion(merged)
            }
        }
    }

    func fetchTasks(userID: UUID, from startDate: Date, to endDate: Date) throws -> [TaskItem] {
        try repository.fetchTasks(forUserID: userID, from: startDate, to: endDate)
    }

    func fetchTasks(userID: UUID, on date: Date) throws -> [TaskItem] {
        try repository.fetchTasks(forUserID: userID, on: date)
    }

    func createTask(input: Input, userID: UUID, completion: @escaping (Result<TaskItem, Error>) -> Void) {
        let planningStart = Calendar.current.startOfDay(for: input.startDate)
        let planningDeadline = Calendar.current.endOfDay(for: input.deadlineDate)

        do {
            if input.isEvent {
                let task = try createEventTask(
                    input: input,
                    userID: userID,
                    planningStart: planningStart,
                    planningDeadline: planningDeadline
                )
                completion(.success(task))
                return
            }

            let appTasks = try repository.fetchTasks(forUserID: userID, from: planningStart, to: planningDeadline)
            fetchCalendarTasks(userID: userID, from: planningStart, to: planningDeadline) { [weak self] calendarTasks in
                guard let self else { return }
                DispatchQueue.main.async {
                    do {
                        let task = try self.createTask(
                            input: input,
                            userID: userID,
                            planningStart: planningStart,
                            planningDeadline: planningDeadline,
                            existingTasks: appTasks + calendarTasks
                        )
                        completion(.success(task))
                    } catch {
                        completion(.failure(error))
                    }
                }
            }
        } catch {
            completion(.failure(error))
        }
    }

    func updateTaskDetails(input: UpdateInput) throws -> TaskItem {
        try repository.updateTaskDetails(
            taskID: input.taskID,
            name: input.name,
            description: input.description,
            importance: input.importance,
            difficulty: input.difficulty
        )
    }

    func toggleCompletion(taskID: UUID) throws {
        try repository.toggleCompletion(taskID: taskID)
    }

    func setCompleted(taskID: UUID) throws {
        try repository.setCompletion(taskID: taskID, isCompleted: true)
    }

    func deleteTask(taskID: UUID) throws {
        try repository.deleteTask(id: taskID)
    }

    func lateBoundary(for task: TaskItem) -> Date? {
        guard !(task.isHardTask && !task.subtasks.isEmpty) else { return nil }

        let calendar = Calendar.current
        guard let boundary = calendar.date(bySettingHour: 23, minute: 0, second: 0, of: task.startDate),
              task.startDate < boundary,
              task.deadlineDate > boundary else {
            return nil
        }
        return boundary
    }

    func splitTaskAtLateBoundary(_ task: TaskItem, userID: UUID) throws -> [TaskItem] {
        guard let boundary = lateBoundary(for: task) else { return [task] }

        let firstDuration = max(0, boundary.timeIntervalSince(task.startDate))
        let remainingDuration = max(0, task.deadlineDate.timeIntervalSince(boundary))
        let updatedTask = try repository.updateTaskSchedule(
            taskID: task.id,
            startDate: task.startDate,
            deadlineDate: boundary,
            estimatedDuration: firstDuration
        )

        var result = [updatedTask]
        if remainingDuration > 0,
           let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: boundary),
           let nextMorning = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: nextDay) {
            let continuation = try repository.createTask(
                name: "\(task.name) (продолжение)",
                description: task.taskDescription,
                startDate: nextMorning,
                deadlineDate: nextMorning.addingTimeInterval(remainingDuration),
                isHardTask: task.isHardTask,
                planningStartDate: task.planningStartDate,
                planningDeadlineDate: task.planningDeadlineDate,
                importance: task.importance,
                difficulty: task.difficulty,
                estimatedDuration: remainingDuration,
                ownerId: userID,
                parentTaskId: nil
            )
            result.append(continuation)
        }

        return result
    }

    private func createEventTask(
        input: Input,
        userID: UUID,
        planningStart: Date,
        planningDeadline: Date
    ) throws -> TaskItem {
        let duration = max(TaskScheduleHelpers.minimumDuration, input.deadlineDate.timeIntervalSince(input.startDate))
        return try repository.createTask(
            name: input.name,
            description: input.description,
            startDate: input.startDate,
            deadlineDate: input.deadlineDate,
            isHardTask: false,
            planningStartDate: planningStart,
            planningDeadlineDate: planningDeadline,
            importance: input.importance,
            difficulty: input.difficulty,
            estimatedDuration: duration,
            ownerId: userID,
            parentTaskId: nil
        )
    }

    private func createTask(
        input: Input,
        userID: UUID,
        planningStart: Date,
        planningDeadline: Date,
        existingTasks: [TaskItem]
    ) throws -> TaskItem {
        let subtaskPlans = input.isHardTask
            ? SubtaskAutoScheduler.schedule(input: input, existingTasks: existingTasks)
            : []

        let slot = input.isHardTask && !subtaskPlans.isEmpty
            ? (
                start: subtaskPlans.map(\.start).min() ?? planningStart,
                end: subtaskPlans.map(\.end).max() ?? planningDeadline
            )
            : TaskAutoScheduler.schedule(input: input, existingTasks: existingTasks)

        var task = try repository.createTask(
            name: input.name,
            description: input.description,
            startDate: slot.start,
            deadlineDate: slot.end,
            isHardTask: input.isHardTask,
            planningStartDate: planningStart,
            planningDeadlineDate: planningDeadline,
            importance: input.importance,
            difficulty: input.difficulty,
            estimatedDuration: input.estimatedDuration,
            ownerId: userID,
            parentTaskId: nil
        )
        for plan in subtaskPlans {
            let subtask = plan.subtask
            let duration = max(15 * 60, subtask.estimatedDuration)
            let createdSubtask = try repository.createTask(
                name: subtask.name,
                description: subtask.description,
                startDate: plan.start,
                deadlineDate: plan.end,
                isHardTask: false,
                planningStartDate: planningStart,
                planningDeadlineDate: planningDeadline,
                importance: subtask.importance,
                difficulty: subtask.difficulty,
                estimatedDuration: duration,
                ownerId: userID,
                parentTaskId: task.id
            )
            task.subtasks.append(createdSubtask)
        }
        task.subtasks.sort { $0.startDate < $1.startDate }
        return task
    }

    private func fetchCalendarTasks(
        userID: UUID,
        from startDate: Date,
        to endDate: Date,
        completion: @escaping ([TaskItem]) -> Void
    ) {
        let calendar = Calendar.current
        var dates: [Date] = []
        var day = calendar.startOfDay(for: startDate)
        let lastDay = calendar.startOfDay(for: endDate)

        while day <= lastDay {
            dates.append(day)
            guard let nextDay = calendar.date(byAdding: .day, value: 1, to: day) else { break }
            day = nextDay
        }

        fetchCalendarTasks(userID: userID, dates: dates, index: 0, tasks: [], completion: completion)
    }

    private func fetchCalendarTasks(
        userID: UUID,
        dates: [Date],
        index: Int,
        tasks: [TaskItem],
        completion: @escaping ([TaskItem]) -> Void
    ) {
        guard index < dates.count else {
            completion(tasks)
            return
        }

        calendarService.fetchEvents(for: dates[index], userID: userID) { [weak self] dayTasks in
            self?.fetchCalendarTasks(
                userID: userID,
                dates: dates,
                index: index + 1,
                tasks: tasks + dayTasks,
                completion: completion
            )
        }
    }

    private static func sortDate(for task: TaskItem) -> Date {
        if task.isHardTask, let firstSubtaskDate = task.subtasks.map(\.startDate).min() {
            return firstSubtaskDate
        }
        return task.startDate
    }
}
