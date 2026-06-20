//
//  StatisticsViewModel.swift
//  lifeisgame
//
//  Created by Codex on 20.06.2026.
//

import Foundation

final class StatisticsViewModel {

    let categoryNames = ["Эмоции", "Сон", "Задачи"]

    var onDiaryStatsLoaded: (([EmotionDiaryEntry], [SleepDiaryEntry]) -> Void)?
    var onTaskStatsLoaded: (([TaskStatsDaySummary]) -> Void)?

    private let diaryService: DiaryService
    private let taskService: TaskService
    private var observerTokens: [NSObjectProtocol] = []

    init(diaryService: DiaryService, taskService: TaskService) {
        self.diaryService = diaryService
        self.taskService = taskService
    }

    deinit {
        observerTokens.forEach(NotificationCenter.default.removeObserver)
    }

    func viewDidLoad() {
        observeChanges()
        refresh()
    }

    func refresh() {
        loadDiaryStats()
        loadTaskStats()
    }

    func categoryName(at index: Int) -> String {
        guard categoryNames.indices.contains(index) else { return "" }
        return categoryNames[index]
    }

    private func observeChanges() {
        guard observerTokens.isEmpty else { return }

        observerTokens.append(NotificationCenter.default.addObserver(
            forName: .diaryStoreDidChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.loadDiaryStats()
        })

        observerTokens.append(NotificationCenter.default.addObserver(
            forName: .taskStoreDidChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.loadTaskStats()
        })
    }

    private func loadDiaryStats() {
        guard let userID = SessionManager.shared.currentUserID else {
            onDiaryStatsLoaded?([], [])
            return
        }

        do {
            onDiaryStatsLoaded?(
                try diaryService.fetchEmotionEntries(forUserID: userID),
                try diaryService.fetchSleepEntries(forUserID: userID)
            )
        } catch {
            onDiaryStatsLoaded?([], [])
        }
    }

    private func loadTaskStats() {
        guard let userID = SessionManager.shared.currentUserID else {
            onTaskStatsLoaded?([])
            return
        }

        let calendar = Calendar.current
        let endDate = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: Date())) ?? Date()
        let startDate = calendar.date(byAdding: .day, value: -29, to: endDate) ?? Date()

        do {
            let tasks = try taskService.fetchTasks(userID: userID, from: startDate, to: endDate)
            onTaskStatsLoaded?(makeTaskSummaries(from: tasks, startDate: startDate, endDate: endDate))
        } catch {
            onTaskStatsLoaded?([])
        }
    }

    private func makeTaskSummaries(from tasks: [TaskItem], startDate: Date, endDate: Date) -> [TaskStatsDaySummary] {
        let calendar = Calendar.current
        let startDay = calendar.startOfDay(for: startDate)
        let endDay = calendar.startOfDay(for: endDate)
        var grouped: [Date: [TaskDayDetailViewController.TaskItem]] = [:]

        for task in tasks {
            for detailTask in makeDetailTasks(from: task) {
                var day = max(calendar.startOfDay(for: detailTask.startDate), startDay)
                while day < endDay {
                    guard let nextDay = calendar.date(byAdding: .day, value: 1, to: day) else { break }
                    if detailTask.startDate < nextDay && detailTask.deadlineDate > day {
                        grouped[day, default: []].append(detailTask)
                    }
                    day = nextDay
                }
            }
        }

        return grouped
            .map { date, tasks in
                let sortedTasks = tasks.sorted { $0.startDate < $1.startDate }
                return TaskStatsDaySummary(
                    date: date,
                    title: formattedTaskStatsDate(date),
                    completed: sortedTasks.filter(\.isCompleted).count,
                    total: sortedTasks.count,
                    tasks: sortedTasks
                )
            }
            .filter { $0.total > 0 }
            .sorted { $0.date > $1.date }
    }

    private func makeDetailTasks(from task: TaskItem) -> [TaskDayDetailViewController.TaskItem] {
        if task.isHardTask && !task.subtasks.isEmpty {
            return task.subtasks.map {
                TaskDayDetailViewController.TaskItem(
                    title: $0.name,
                    typeTitle: "Подзадача",
                    mainTaskName: task.name,
                    startDate: $0.startDate,
                    deadlineDate: $0.deadlineDate,
                    importance: $0.importance,
                    isCompleted: $0.isCompleted
                )
            }
        }

        return [
            TaskDayDetailViewController.TaskItem(
                title: task.name,
                typeTitle: task.isHardTask ? "Сложная задача" : "Задача",
                mainTaskName: nil,
                startDate: task.startDate,
                deadlineDate: task.deadlineDate,
                importance: task.importance,
                isCompleted: task.isCompleted
            )
        ]
    }

    private func formattedTaskStatsDate(_ date: Date) -> String {
        let calendar = Calendar.current
        let dateText = DateFormatter.appDateString(from: date)

        if calendar.isDateInToday(date) {
            return "Сегодня, \(dateText)"
        }
        if calendar.isDateInYesterday(date) {
            return "Вчера, \(dateText)"
        }

        return DateFormatter.appWeekdayDateString(from: date)
    }
}
