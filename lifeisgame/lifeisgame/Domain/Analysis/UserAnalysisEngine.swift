//
//  UserAnalysisEngine.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 12.05.2026.
//

import Foundation

protocol UserAnalysisEngineProtocol {
    func analyze(input: UserAnalysisInput) -> UserAnalysisResult
}

private struct EmotionAnalysisState {
    let balance: Double?
    let strain: Double
    let support: Double
}

private struct SleepAnalysisTrend {
    let averageMinutes: Int?
    let scheduleVariationMinutes: Int?
    let entryCount: Int
}

private struct DayLoadAnalysis {
    let score: Int
    let availableFocusMinutes: Int
    let fixedEventMinutes: Int
    let overdueTaskCount: Int
}

struct UserAnalysisEngine: UserAnalysisEngineProtocol {

    private let calendar: Calendar

    init(calendar: Calendar = .current) {
        self.calendar = calendar
    }

    func analyze(input: UserAnalysisInput) -> UserAnalysisResult {
        let age = age(from: input.user.birthDate, on: input.date)
        let sleepRange = SleepRecommendation.rangeMinutes(forAge: age)
        let sleep = sleepEntry(for: input.date, from: input.sleepEntries)
        let sleepMinutes = sleep?.durationMinutes
        let sleepTrend = sleepTrend(on: input.date, entries: input.sleepEntries)

        let allTodayItems = workItems(from: input.todayTasks)
        let todayItems = allTodayItems.filter { !$0.isCompleted }
        let completedItems = allTodayItems.filter(\.isCompleted)
        let tomorrowItems = workItems(from: input.tomorrowTasks).filter { !$0.isCompleted }
        let todayWorkloadScore = workloadScore(for: todayItems)
        let tomorrowWorkloadScore = workloadScore(for: tomorrowItems)
        let averageDifficulty = todayItems.isEmpty
            ? 0
            : todayItems.map { Double($0.difficulty) }.reduce(0, +) / Double(todayItems.count)
        let emotionState = emotionState(on: input.date, entries: input.emotionEntries)
        let resourceScore = resourceScore(
            sleepMinutes: sleepMinutes,
            averageSleepMinutes: sleepTrend.averageMinutes,
            recommendedSleepRange: sleepRange,
            emotionalStrain: emotionState.strain,
            emotionalSupport: emotionState.support,
            hasEmotionData: emotionState.balance != nil
        )
        let load = dayLoad(
            on: input.date,
            remainingTasks: todayItems,
            completedTasks: completedItems
        )
        let loadScore = load.score
        let balanceScore = Int(max(0, min(100, 50 + Double(resourceScore - loadScore) * 0.65)).rounded())
        let confidenceScore = confidenceScore(
            user: input.user,
            sleep: sleep,
            recentSleepEntryCount: sleepTrend.entryCount,
            hasEmotionData: emotionState.balance != nil
        )
        let confidenceLevel = confidenceLevel(for: confidenceScore)
        let readinessScore = confidenceLevel == .low ? resourceScore : balanceScore

        let metrics = UserAnalysisMetrics(
            age: age,
            sleepDurationMinutes: sleepMinutes,
            recommendedSleepRangeMinutes: sleepRange,
            todayTaskCount: todayItems.count,
            completedTaskCount: completedItems.count,
            todayHardTaskCount: hardTaskCount(in: todayItems),
            tomorrowTaskCount: tomorrowItems.count,
            tomorrowHardTaskCount: hardTaskCount(in: tomorrowItems),
            averageDifficulty: averageDifficulty,
            completedEstimatedMinutes: estimatedMinutes(for: completedItems),
            remainingEstimatedMinutes: estimatedMinutes(for: todayItems),
            availableFocusMinutes: load.availableFocusMinutes,
            fixedEventMinutes: load.fixedEventMinutes,
            overdueTaskCount: load.overdueTaskCount,
            averageSleepMinutes: sleepTrend.averageMinutes,
            sleepScheduleVariationMinutes: sleepTrend.scheduleVariationMinutes,
            todayWorkloadScore: todayWorkloadScore,
            tomorrowWorkloadScore: tomorrowWorkloadScore,
            emotionBalance: emotionState.balance,
            emotionalStrain: emotionState.strain,
            emotionalSupport: emotionState.support
        )

        return UserAnalysisResult(
            readinessScore: readinessScore,
            resourceScore: resourceScore,
            loadScore: loadScore,
            balanceScore: balanceScore,
            confidenceScore: confidenceScore,
            confidenceLevel: confidenceLevel,
            workloadLevel: workloadLevel(for: Double(loadScore)),
            summary: summary(
                for: metrics,
                resourceScore: resourceScore,
                loadScore: loadScore,
                confidenceLevel: confidenceLevel
            ),
            signals: signals(
                from: metrics,
                resourceScore: resourceScore,
                loadScore: loadScore,
                balanceScore: balanceScore,
                confidenceLevel: confidenceLevel
            ),
            advices: UserAnalysisAdviceEngine(calendar: calendar).makeAdvices(
                metrics: metrics,
                readinessScore: readinessScore,
                loadScore: loadScore,
                todayTasks: todayItems,
                tomorrowTasks: tomorrowItems,
                date: input.date
            ),
            metrics: metrics
        )
    }
}

private extension UserAnalysisEngine {
    private func age(from birthDate: Date?, on date: Date) -> Int? {
        guard let birthDate else { return nil }
        guard let years = calendar.dateComponents([.year], from: birthDate, to: date).year else { return nil }
        return max(0, years)
    }

    private func sleepEntry(for date: Date, from entries: [SleepDiaryEntry]) -> SleepDiaryEntry? {
        let day = calendar.startOfDay(for: date)
        if let sameDay = entries.first(where: { calendar.isDate($0.dayDate, inSameDayAs: day) }) {
            return sameDay
        }

        guard let yesterday = calendar.date(byAdding: .day, value: -1, to: day) else { return nil }
        return entries.first { calendar.isDate($0.dayDate, inSameDayAs: yesterday) }
    }

    private func sleepTrend(on date: Date, entries: [SleepDiaryEntry]) -> SleepAnalysisTrend {
        let day = calendar.startOfDay(for: date)
        let start = calendar.date(byAdding: .day, value: -6, to: day) ?? day
        let end = calendar.date(byAdding: .day, value: 1, to: day) ?? day
        let recent = entries.filter { entry in
            entry.dayDate >= start && entry.dayDate < end
        }
        guard !recent.isEmpty else {
            return SleepAnalysisTrend(
                averageMinutes: nil,
                scheduleVariationMinutes: nil,
                entryCount: 0
            )
        }

        let average = recent.map(\.durationMinutes).reduce(0, +) / recent.count
        let bedtimes = recent.map { normalizedBedtimeMinute($0.bedtime) }
        let averageBedtime = bedtimes.reduce(0, +) / bedtimes.count
        let variation = bedtimes.map { abs($0 - averageBedtime) }.reduce(0, +) / bedtimes.count
        return SleepAnalysisTrend(
            averageMinutes: average,
            scheduleVariationMinutes: variation,
            entryCount: recent.count
        )
    }

    private func normalizedBedtimeMinute(_ date: Date) -> Int {
        let components = calendar.dateComponents([.hour, .minute], from: date)
        let hour = components.hour ?? 0
        return (hour < 12 ? hour + 24 : hour) * 60 + (components.minute ?? 0)
    }

    private func workItems(from tasks: [TaskItem]) -> [TaskItem] {
        tasks.flatMap { task in
            task.isHardTask && !task.subtasks.isEmpty ? task.subtasks : [task]
        }
    }

    private func hardTaskCount(in tasks: [TaskItem]) -> Int {
        tasks.filter { $0.difficulty >= 7 || $0.importance >= 8 }.count
    }

    private func workloadScore(for tasks: [TaskItem]) -> Double {
        guard !tasks.isEmpty else { return 0 }

        let taskCountPressure = min(Double(tasks.count) / 7, 1)
        let minimumDuration: TimeInterval = 15 * 60
        let maximumDuration: TimeInterval = 8 * 60 * 60
        let estimatedSeconds = tasks.reduce(0) { partialResult, task in
            partialResult + max(minimumDuration, min(task.estimatedDuration, maximumDuration))
        }
        let estimatedHours = estimatedSeconds / 3600
        let durationPressure = min(estimatedHours / 7, 1)
        let difficultyPressure = tasks.map { Double(max(1, min(10, $0.difficulty))) }.reduce(0, +) / Double(tasks.count) / 10
        let importancePressure = tasks.map { Double(max(1, min(10, $0.importance))) }.reduce(0, +) / Double(tasks.count) / 10

        return min(
            100,
            (taskCountPressure * 0.28 + durationPressure * 0.34 + difficultyPressure * 0.24 + importancePressure * 0.14) * 100
        )
    }

    private func estimatedMinutes(for tasks: [TaskItem]) -> Int {
        tasks.reduce(0) { total, task in
            let seconds = max(15 * 60, min(task.estimatedDuration, 8 * 60 * 60))
            return total + Int(seconds / 60)
        }
    }

    private func dayLoad(
        on date: Date,
        remainingTasks: [TaskItem],
        completedTasks: [TaskItem]
    ) -> DayLoadAnalysis {
        let fixedEvents = remainingTasks.filter { $0.source == .calendar }
        let flexibleTasks = remainingTasks.filter { $0.source != .calendar }
        let fixedMinutes = occupiedMinutes(for: fixedEvents, after: date)
        let availableMinutes = max(0, availableMinutes(on: date) - fixedMinutes)
        let remainingEffort = weightedEffortMinutes(for: flexibleTasks)
        let completedEffort = weightedEffortMinutes(for: completedTasks)
        let overdueCount = remainingTasks.filter { $0.deadlineDate < date }.count

        let remainingPressure = min(
            1,
            remainingEffort / Double(max(60, availableMinutes)) / 1.5
        )
        let spentPressure = min(1, completedEffort / 480)
        let urgencyPressure = min(1, Double(overdueCount) / 3)
        let fragmentationPressure = min(1, Double(remainingTasks.count) / 8)
        let score = Int(min(
            100,
            remainingPressure * 80
                + spentPressure * 12
                + urgencyPressure * 6
                + fragmentationPressure * 2
        ).rounded())

        return DayLoadAnalysis(
            score: score,
            availableFocusMinutes: availableMinutes,
            fixedEventMinutes: fixedMinutes,
            overdueTaskCount: overdueCount
        )
    }

    private func availableMinutes(on date: Date) -> Int {
        let dayStart = calendar.startOfDay(for: date)
        let workStart = calendar.date(bySettingHour: 8, minute: 0, second: 0, of: dayStart) ?? dayStart
        let workEnd = calendar.date(bySettingHour: 22, minute: 0, second: 0, of: dayStart) ?? dayStart
        let start = max(date, workStart)
        guard start < workEnd else { return 0 }
        return min(8 * 60, Int(workEnd.timeIntervalSince(start) / 60))
    }

    private func occupiedMinutes(for tasks: [TaskItem], after date: Date) -> Int {
        let dayStart = calendar.startOfDay(for: date)
        let workEnd = calendar.date(bySettingHour: 22, minute: 0, second: 0, of: dayStart) ?? dayStart
        let intervals = tasks
            .map { (start: max(date, $0.startDate), end: min(workEnd, $0.deadlineDate)) }
            .filter { $0.end > $0.start }
            .sorted { $0.start < $1.start }
        guard let first = intervals.first else { return 0 }

        var total: TimeInterval = 0
        var currentStart = first.start
        var currentEnd = first.end
        for interval in intervals.dropFirst() {
            if interval.start <= currentEnd {
                currentEnd = max(currentEnd, interval.end)
            } else {
                total += currentEnd.timeIntervalSince(currentStart)
                currentStart = interval.start
                currentEnd = interval.end
            }
        }
        total += currentEnd.timeIntervalSince(currentStart)
        return Int(total / 60)
    }

    private func weightedEffortMinutes(for tasks: [TaskItem]) -> Double {
        tasks.reduce(0) { result, task in
            let minutes = Double(max(15, min(8 * 60, Int(task.estimatedDuration / 60))))
            let difficultyFactor = 0.75 + Double(max(1, min(10, task.difficulty))) * 0.05
            return result + minutes * difficultyFactor
        }
    }

    private func workloadLevel(for score: Double) -> UserWorkloadLevel {
        switch score {
        case 0..<28:
            return .low
        case 28..<58:
            return .balanced
        case 58..<78:
            return .high
        default:
            return .overloaded
        }
    }

    private func emotionState(
        on date: Date,
        entries: [EmotionDiaryEntry]
    ) -> EmotionAnalysisState {
        let todayEntries = entries.filter { calendar.isDate($0.dayDate, inSameDayAs: date) }
        guard !todayEntries.isEmpty else {
            return EmotionAnalysisState(balance: nil, strain: 0, support: 0)
        }

        let scores = todayEntries.map { entry -> Double in
            let direction = emotionDirection(for: entry.emotionName)
            return Double(entry.intensity) / 10 * direction
        }
        let negativeScores = scores.filter { $0 < 0 }.map { abs($0) }
        let positiveScores = scores.filter { $0 > 0 }
        let strain = negativeScores.max() ?? 0
        let support = positiveScores.max() ?? 0
        let balance = scores.reduce(0, +) / Double(scores.count)
        return EmotionAnalysisState(balance: balance, strain: strain, support: support)
    }

    private func emotionDirection(for name: String) -> Double {
        EmotionKind(rawValue: name)?.valence ?? 0
    }

    private func resourceScore(
        sleepMinutes: Int?,
        averageSleepMinutes: Int?,
        recommendedSleepRange: ClosedRange<Int>,
        emotionalStrain: Double,
        emotionalSupport: Double,
        hasEmotionData: Bool
    ) -> Int {
        var components: [(value: Double, weight: Double)] = []
        if let sleepMinutes {
            let currentSleepScore = sleepScore(
                minutes: sleepMinutes,
                recommendedRange: recommendedSleepRange
            )
            let trendSleepScore = averageSleepMinutes.map {
                self.sleepScore(minutes: $0, recommendedRange: recommendedSleepRange)
            } ?? currentSleepScore
            let combinedSleepScore = currentSleepScore * 0.65 + trendSleepScore * 0.35
            components.append((combinedSleepScore, 0.65))
        }

        if hasEmotionData {
            let emotionalResource = max(
                0,
                min(100, 55 + emotionalSupport * 25 - emotionalStrain * 40)
            )
            components.append((emotionalResource, 0.35))
        }

        guard !components.isEmpty else { return 50 }
        let totalWeight = components.reduce(0) { $0 + $1.weight }
        let weightedScore = components.reduce(0) { $0 + $1.value * $1.weight } / totalWeight
        return Int(max(0, min(100, weightedScore)).rounded())
    }

    private func sleepScore(
        minutes: Int,
        recommendedRange: ClosedRange<Int>
    ) -> Double {
        guard minutes < recommendedRange.lowerBound else { return 100 }
        return max(
            0,
            Double(minutes) / Double(max(1, recommendedRange.lowerBound)) * 100
        )
    }

    private func confidenceScore(
        user: User,
        sleep: SleepDiaryEntry?,
        recentSleepEntryCount: Int,
        hasEmotionData: Bool
    ) -> Int {
        var score = 20
        if user.birthDate != nil { score += 10 }
        if sleep != nil { score += 30 }
        if recentSleepEntryCount >= 3 { score += 15 }
        if hasEmotionData { score += 25 }
        return min(100, score)
    }

    private func confidenceLevel(for score: Int) -> UserAnalysisConfidenceLevel {
        switch score {
        case 0..<45:
            return .low
        case 45..<75:
            return .medium
        default:
            return .high
        }
    }

    private func summary(
        for metrics: UserAnalysisMetrics,
        resourceScore: Int,
        loadScore: Int,
        confidenceLevel: UserAnalysisConfidenceLevel
    ) -> String {
        let sleepText = metrics.sleepDurationMinutes.map(durationText) ?? "сон не указан"
        let workText = "осталось \(metrics.todayTaskCount), выполнено \(metrics.completedTaskCount)"

        if confidenceLevel == .low {
            return "Предварительный анализ: данных пока недостаточно. \(sleepText), задач — \(workText)."
        }

        return "Ресурс \(resourceScore)/100, нагрузка \(loadScore)/100: \(sleepText), задач — \(workText), на завтра \(metrics.tomorrowTaskCount)."
    }

    private func signals(
        from metrics: UserAnalysisMetrics,
        resourceScore: Int,
        loadScore: Int,
        balanceScore: Int,
        confidenceLevel: UserAnalysisConfidenceLevel
    ) -> [String] {
        var result = [
            "Ресурс \(resourceScore)/100",
            "Нагрузка \(loadScore)/100",
            "Баланс \(balanceScore)/100",
            "Точность: \(confidenceLevel.title)",
            "Доступно \(durationText(metrics.availableFocusMinutes))",
            "Осталось \(durationText(metrics.remainingEstimatedMinutes))",
            "Выполнено \(durationText(metrics.completedEstimatedMinutes))"
        ]

        if let sleepDuration = metrics.sleepDurationMinutes {
            result.append("Последний сон \(durationText(sleepDuration))")
        } else {
            result.append("Сон не заполнен")
        }

        if let averageSleep = metrics.averageSleepMinutes {
            result.append("Сон 7 дней \(durationText(averageSleep))")
        }
        if let variation = metrics.sleepScheduleVariationMinutes, variation > 0 {
            result.append("Разброс отбоя ~\(variation)м")
        }

        result.append("Завтра \(metrics.tomorrowTaskCount) задач")
        if metrics.fixedEventMinutes > 0 {
            result.append("События \(durationText(metrics.fixedEventMinutes))")
        }
        if metrics.overdueTaskCount > 0 {
            result.append("Просрочено \(metrics.overdueTaskCount)")
        }
        if metrics.emotionBalance != nil {
            result.append("Напряжение \(Int((metrics.emotionalStrain * 100).rounded()))%")
            result.append("Поддержка \(Int((metrics.emotionalSupport * 100).rounded()))%")
        }

        return result
    }

    private func durationText(_ minutes: Int) -> String {
        let hours = minutes / 60
        let restMinutes = minutes % 60
        return "\(hours)ч \(restMinutes)м"
    }
}
