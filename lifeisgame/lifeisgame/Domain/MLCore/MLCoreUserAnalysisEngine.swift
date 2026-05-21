//
//  MLCoreUserAnalysisEngine.swift
//  lifeisgame
//
//  Created by Codex on 19.05.2026.
//

import Foundation

protocol UserAnalysisEngineProtocol {
    func analyze(input: UserAnalysisInput) -> UserAnalysisResult
}

final class MLCoreUserAnalysisEngine: UserAnalysisEngineProtocol {

    private let calendar: Calendar

    init(calendar: Calendar = .current) {
        self.calendar = calendar
    }

    func analyze(input: UserAnalysisInput) -> UserAnalysisResult {
        let age = age(from: input.user.birthDate, on: input.date)
        let sleepRange = recommendedSleepRangeMinutes(forAge: age)
        let sleep = sleepEntry(for: input.date, from: input.sleepEntries)
        let sleepMinutes = sleep?.durationMinutes

        let todayItems = workItems(from: input.todayTasks).filter { !$0.isCompleted }
        let tomorrowItems = workItems(from: input.tomorrowTasks).filter { !$0.isCompleted }
        let todayWorkloadScore = workloadScore(for: todayItems)
        let tomorrowWorkloadScore = workloadScore(for: tomorrowItems)
        let averageDifficulty = todayItems.isEmpty ? 0 : todayItems.map { Double($0.difficulty) }.reduce(0, +) / Double(todayItems.count)
        let emotionBalance = emotionBalance(on: input.date, entries: input.emotionEntries)
        let readinessScore = readinessScore(
            sleepMinutes: sleepMinutes,
            recommendedSleepRange: sleepRange,
            todayWorkloadScore: todayWorkloadScore,
            tomorrowWorkloadScore: tomorrowWorkloadScore,
            emotionBalance: emotionBalance
        )

        let metrics = UserAnalysisMetrics(
            age: age,
            sleepDurationMinutes: sleepMinutes,
            recommendedSleepRangeMinutes: sleepRange,
            todayTaskCount: todayItems.count,
            todayHardTaskCount: hardTaskCount(in: todayItems),
            tomorrowTaskCount: tomorrowItems.count,
            tomorrowHardTaskCount: hardTaskCount(in: tomorrowItems),
            averageDifficulty: averageDifficulty,
            todayWorkloadScore: todayWorkloadScore,
            tomorrowWorkloadScore: tomorrowWorkloadScore,
            emotionBalance: emotionBalance
        )

        return UserAnalysisResult(
            readinessScore: readinessScore,
            workloadLevel: workloadLevel(for: todayWorkloadScore),
            summary: summary(for: metrics, readinessScore: readinessScore),
            signals: signals(from: metrics),
            advices: advices(from: metrics, readinessScore: readinessScore),
            metrics: metrics
        )
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

    private func sleepEntry(for date: Date, from entries: [SleepDiaryEntry]) -> SleepDiaryEntry? {
        let day = calendar.startOfDay(for: date)
        if let sameDay = entries.first(where: { calendar.isDate($0.dayDate, inSameDayAs: day) }) {
            return sameDay
        }

        guard let yesterday = calendar.date(byAdding: .day, value: -1, to: day) else { return nil }
        return entries.first { calendar.isDate($0.dayDate, inSameDayAs: yesterday) }
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

    private func emotionBalance(on date: Date, entries: [EmotionDiaryEntry]) -> Double? {
        let todayEntries = entries.filter { calendar.isDate($0.dayDate, inSameDayAs: date) }
        guard !todayEntries.isEmpty else { return nil }

        let scores = todayEntries.map { entry -> Double in
            let direction = emotionDirection(for: entry.emotionName)
            return Double(entry.intensity) / 10 * direction
        }
        return scores.reduce(0, +) / Double(scores.count)
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

    private func readinessScore(
        sleepMinutes: Int?,
        recommendedSleepRange: ClosedRange<Int>,
        todayWorkloadScore: Double,
        tomorrowWorkloadScore: Double,
        emotionBalance: Double?
    ) -> Int {
        var score = 86

        if let sleepMinutes {
            if sleepMinutes < recommendedSleepRange.lowerBound {
                let deficitHours = Double(recommendedSleepRange.lowerBound - sleepMinutes) / 60
                score -= Int(deficitHours * 11)
            } else if sleepMinutes > recommendedSleepRange.upperBound + 90 {
                score -= 6
            } else {
                score += 4
            }
        } else {
            score -= 8
        }

        score -= Int(todayWorkloadScore * 0.28)
        score -= Int(tomorrowWorkloadScore * 0.08)

        if let emotionBalance {
            if emotionBalance < -0.45 {
                score -= 14
            } else if emotionBalance > 0.45 {
                score += 6
            }
        }

        return max(10, min(100, score))
    }

    private func summary(for metrics: UserAnalysisMetrics, readinessScore: Int) -> String {
        let sleepText = metrics.sleepDurationMinutes.map(durationText) ?? "сон не указан"
        let readinessText: String

        switch readinessScore {
        case 76...100:
            readinessText = "ресурс хороший"
        case 52..<76:
            readinessText = "ресурс средний"
        default:
            readinessText = "ресурс снижен"
        }

        return "Сегодня \(readinessText): \(sleepText), задач на сегодня \(metrics.todayTaskCount), на завтра \(metrics.tomorrowTaskCount)."
    }

    private func signals(from metrics: UserAnalysisMetrics) -> [String] {
        var result: [String] = []

        if let sleepDuration = metrics.sleepDurationMinutes {
            result.append("Сон \(durationText(sleepDuration))")
        } else {
            result.append("Сон не заполнен")
        }

        result.append("Сегодня \(metrics.todayTaskCount) задач")
        result.append("Сложных \(metrics.todayHardTaskCount)")
        result.append("Завтра \(metrics.tomorrowTaskCount) задач")

        if let age = metrics.age {
            result.append("Возраст \(age)")
        }

        return result
    }

    private func advices(from metrics: UserAnalysisMetrics, readinessScore: Int) -> [UserAnalysisAdvice] {
        var result: [UserAnalysisAdvice] = []

        if let sleepMinutes = metrics.sleepDurationMinutes {
            if sleepMinutes < metrics.recommendedSleepRangeMinutes.lowerBound {
                result.append(UserAnalysisAdvice(
                    title: "Сон снижает ресурс",
                    message: "Сегодня получилось \(durationText(sleepMinutes)). Это может снизить концентрацию, поэтому лучше поставить самые сложные задачи на первую половину дня и оставить паузы.",
                    sfSymbol: "moon.zzz.fill",
                    priority: .high
                ))
            } else if sleepMinutes > metrics.recommendedSleepRangeMinutes.upperBound + 90 {
                result.append(UserAnalysisAdvice(
                    title: "Начни мягче",
                    message: "Сон был длиннее обычного. Дай организму разогнаться: начни с короткой задачи и только потом переходи к сложной.",
                    sfSymbol: "sunrise.fill",
                    priority: .medium
                ))
            }
        } else {
            result.append(UserAnalysisAdvice(
                title: "Добавь сон",
                message: "Заполни дневник сна, чтобы анализ точнее понимал продуктивность и нагрузку на день.",
                sfSymbol: "bed.double.fill",
                priority: .medium
            ))
        }

        if metrics.todayWorkloadScore >= 78 || (metrics.todayTaskCount >= 7 && metrics.todayHardTaskCount >= 3) {
            result.append(UserAnalysisAdvice(
                title: "Сегодня перегруз",
                message: "На день много задач и высокая сложность. Выбери 2-3 обязательные, остальное перенеси или разбей на маленькие шаги.",
                sfSymbol: "exclamationmark.triangle.fill",
                priority: .high
            ))
        } else if metrics.todayWorkloadScore >= 58 {
            result.append(UserAnalysisAdvice(
                title: "Держи фокус",
                message: "Нагрузка высокая, но управляемая. Планируй блоками по 45-60 минут и не добавляй новые задачи до завершения главных.",
                sfSymbol: "target",
                priority: .medium
            ))
        }

        if metrics.tomorrowWorkloadScore >= 65 || metrics.tomorrowTaskCount >= 7 {
            result.append(UserAnalysisAdvice(
                title: "Завтра высокая нагрузка",
                message: "На завтра уже много задач. Сегодня лучше не добавлять новые дела на завтра и лечь пораньше.",
                sfSymbol: "calendar.badge.exclamationmark",
                priority: .high
            ))
        }

        if let emotionBalance = metrics.emotionBalance {
            if emotionBalance <= -0.45 {
                result.append(UserAnalysisAdvice(
                    title: "Эмоции забирают энергию",
                    message: "Сегодня отмечены напряженные эмоции. Снизь планку на вечер и оставь место для восстановления.",
                    sfSymbol: "heart.text.square.fill",
                    priority: .medium
                ))
            } else if emotionBalance >= 0.45 && readinessScore >= 60 {
                result.append(UserAnalysisAdvice(
                    title: "Хорошее окно для сложного",
                    message: "Эмоциональный фон помогает работе. Используй это для одной важной задачи, а не для бесконечного списка.",
                    sfSymbol: "sparkles",
                    priority: .info
                ))
            }
        } else {
            result.append(UserAnalysisAdvice(
                title: "Отметь эмоции",
                message: "Короткая запись эмоций поможет понять, когда нагрузка начинает влиять на продуктивность.",
                sfSymbol: "face.smiling.fill",
                priority: .info
            ))
        }

        if let age = metrics.age, age < 18, metrics.todayWorkloadScore >= 58 {
            result.append(UserAnalysisAdvice(
                title: "Нужен запас на восстановление",
                message: "Для твоего возраста сон и паузы особенно важны. Не ставь слишком много задач подряд.",
                sfSymbol: "battery.75percent",
                priority: .medium
            ))
        }

        if result.isEmpty {
            result.append(UserAnalysisAdvice(
                title: "День выглядит устойчиво",
                message: "Нагрузка, сон и эмоции сейчас не выглядят конфликтующими. Держи план коротким и закрывай задачи по приоритету.",
                sfSymbol: "checkmark.seal.fill",
                priority: .info
            ))
        }

        return result
            .sorted { $0.priority.rawValue > $1.priority.rawValue }
            .prefix(4)
            .map { $0 }
    }

    private func durationText(_ minutes: Int) -> String {
        let hours = minutes / 60
        let restMinutes = minutes % 60
        return "\(hours)ч \(restMinutes)м"
    }
}
