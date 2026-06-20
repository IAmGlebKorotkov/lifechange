//
//  AnalysisService.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 19.06.2026.
//

import Foundation

final class AnalysisService {

    private let authService: AuthService
    private let diaryService: DiaryService
    private let taskService: TaskService
    private let analysisEngine: UserAnalysisEngineProtocol
    private let calendar: Calendar

    init(
        authService: AuthService = AuthService(),
        diaryService: DiaryService = DiaryService(),
        taskService: TaskService = TaskService(),
        analysisEngine: UserAnalysisEngineProtocol = UserAnalysisEngine(),
        calendar: Calendar = .current
    ) {
        self.authService = authService
        self.diaryService = diaryService
        self.taskService = taskService
        self.analysisEngine = analysisEngine
        self.calendar = calendar
    }

    func analyzeUserDay(
        userID: UUID,
        date: Date = Date(),
        completion: @escaping (Result<UserAnalysisResult, Error>) -> Void
    ) {
        let input: UserAnalysisInput

        do {
            guard let user = try authService.fetchUser(byID: userID) else {
                throw RepositoryError.notFound
            }

            let tomorrow = calendar.date(byAdding: .day, value: 1, to: date) ?? date
            input = UserAnalysisInput(
                user: user,
                date: date,
                todayTasks: try taskService.fetchTasks(userID: userID, on: date),
                tomorrowTasks: try taskService.fetchTasks(userID: userID, on: tomorrow),
                emotionEntries: try diaryService.fetchEmotionEntries(forUserID: userID),
                sleepEntries: try diaryService.fetchSleepEntries(forUserID: userID)
            )
        } catch {
            DispatchQueue.main.async {
                completion(.failure(error))
            }
            return
        }

        DispatchQueue.main.async {
            completion(.success(self.analysisEngine.analyze(input: input)))
        }
    }

    func weeklyStats(userID: UUID, date: Date = Date()) throws -> GeneralWeeklyStats {
        let today = calendar.startOfDay(for: date)
        let endDate = calendar.date(byAdding: .day, value: 1, to: today) ?? date
        let startDate = calendar.date(byAdding: .day, value: -6, to: today) ?? today

        let user = try authService.fetchUser(byID: userID)
        let taskItems = try taskService.fetchTasks(userID: userID, from: startDate, to: endDate)
        let sleepEntries = try diaryService.fetchSleepEntries(forUserID: userID)
        let emotionEntries = try diaryService.fetchEmotionEntries(forUserID: userID)

        let tasks = workItems(from: taskItems, startDate: startDate, endDate: endDate)
        let completedTasks = tasks.filter(\.isCompleted).count
        let recommendedSleepRange = recommendedSleepRangeMinutes(
            forAge: age(from: user?.birthDate, on: date)
        )

        return GeneralWeeklyStats(
            completedTasks: completedTasks,
            totalTasks: tasks.count,
            sleepQuality: sleepQuality(
                from: sleepEntries,
                startDate: startDate,
                endDate: endDate,
                recommendedRange: recommendedSleepRange
            ),
            efficiency: taskEfficiency(from: tasks),
            mood: moodScore(from: emotionEntries, startDate: startDate, endDate: endDate)
        )
    }

    private func workItems(from tasks: [TaskItem], startDate: Date, endDate: Date) -> [TaskItem] {
        tasks
            .flatMap { task in
                task.isHardTask && !task.subtasks.isEmpty ? task.subtasks : [task]
            }
            .filter { $0.startDate < endDate && $0.deadlineDate > startDate }
    }

    private func sleepQuality(
        from entries: [SleepDiaryEntry],
        startDate: Date,
        endDate: Date,
        recommendedRange: ClosedRange<Int>
    ) -> Double {
        let weekEntries = entries.filter { $0.dayDate >= startDate && $0.dayDate < endDate }
        guard !weekEntries.isEmpty else { return 0 }

        let scores = weekEntries.map { sleepQualityScore($0.durationMinutes, recommendedRange: recommendedRange) }
        return scores.reduce(0, +) / Double(scores.count)
    }

    private func sleepQualityScore(_ minutes: Int, recommendedRange: ClosedRange<Int>) -> Double {
        if recommendedRange.contains(minutes) { return 1 }

        if minutes < recommendedRange.lowerBound {
            return max(0, Double(minutes) / Double(max(recommendedRange.lowerBound, 1)))
        }

        let extraMinutes = Double(minutes - recommendedRange.upperBound)
        return max(0, 1 - extraMinutes / 240)
    }

    private func taskEfficiency(from tasks: [TaskItem]) -> Double {
        let totalWeight = tasks.reduce(0) { $0 + taskWeight($1) }
        guard totalWeight > 0 else { return 0 }

        let completedWeight = tasks
            .filter(\.isCompleted)
            .reduce(0) { $0 + taskWeight($1) }
        return max(0, min(1, completedWeight / totalWeight))
    }

    private func taskWeight(_ task: TaskItem) -> Double {
        let durationHours = max(0.25, min(8, task.estimatedDuration / 3600))
        let difficultyFactor = 0.55 + Double(max(1, min(10, task.difficulty))) / 20
        let importanceFactor = 0.65 + Double(max(1, min(10, task.importance))) / 30
        return durationHours * difficultyFactor * importanceFactor
    }

    private func moodScore(from entries: [EmotionDiaryEntry], startDate: Date, endDate: Date) -> Double {
        let weekEntries = entries.filter { $0.dayDate >= startDate && $0.dayDate < endDate }
        guard !weekEntries.isEmpty else { return 0 }

        let balance = weekEntries
            .map { emotionBalance(for: $0) }
            .reduce(0, +) / Double(weekEntries.count)
        return max(0, min(1, (balance + 1) / 2))
    }

    private func emotionBalance(for entry: EmotionDiaryEntry) -> Double {
        Double(max(1, min(10, entry.intensity))) / 10 * emotionDirection(for: entry.emotionName)
    }

    private func emotionDirection(for name: String) -> Double {
        let lowercasedName = name.lowercased()

        if lowercasedName.contains("трев")
            || lowercasedName.contains("груст")
            || lowercasedName.contains("зл")
            || lowercasedName.contains("страх") {
            return -1
        }

        if lowercasedName.contains("рад")
            || lowercasedName.contains("поко")
            || lowercasedName.contains("люб")
            || lowercasedName.contains("споко") {
            return 1
        }

        return 0
    }

    private func age(from birthDate: Date?, on date: Date) -> Int? {
        guard let birthDate else { return nil }
        guard let years = calendar.dateComponents([.year], from: birthDate, to: date).year else { return nil }
        return max(0, years)
    }

    private func recommendedSleepRangeMinutes(forAge age: Int?) -> ClosedRange<Int> {
        guard let age else { return (7 * 60)...(9 * 60) }

        if age < 18 {
            return (8 * 60)...(10 * 60)
        }

        if age >= 65 {
            return (7 * 60)...(8 * 60 + 30)
        }

        return (7 * 60)...(9 * 60)
    }
}
