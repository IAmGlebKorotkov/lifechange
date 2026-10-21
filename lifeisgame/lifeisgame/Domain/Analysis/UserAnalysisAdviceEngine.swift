//
//  UserAnalysisAdviceEngine.swift
//  lifeisgame
//

import Foundation

struct UserAnalysisAdviceEngine {

    private let calendar: Calendar

    init(calendar: Calendar) {
        self.calendar = calendar
    }

    func makeAdvices(
        metrics: UserAnalysisMetrics,
        readinessScore: Int,
        loadScore: Int,
        todayTasks: [TaskItem],
        tomorrowTasks: [TaskItem],
        date: Date
    ) -> [UserAnalysisAdvice] {
        var result = [
            sleepAdvice(metrics: metrics, date: date),
            loadAdvice(metrics: metrics, loadScore: loadScore, tasks: todayTasks),
            overdueAdvice(metrics: metrics, tasks: todayTasks, date: date),
            tomorrowAdvice(metrics: metrics, tasks: tomorrowTasks),
            emotionAdvice(metrics: metrics, readinessScore: readinessScore)
        ].compactMap { $0 }

        if result.isEmpty {
            result.append(UserAnalysisAdvice(
                title: "День выглядит устойчиво",
                message: "Ресурс и текущий план не конфликтуют. Сохраняй запас между задачами и закрывай их по важности.",
                sfSymbol: "checkmark.seal.fill",
                priority: .info
            ))
        }

        return result
            .sorted { $0.priority.rawValue > $1.priority.rawValue }
            .prefix(4)
            .map { $0 }
    }

    private func sleepAdvice(metrics: UserAnalysisMetrics, date: Date) -> UserAnalysisAdvice? {
        guard let sleepMinutes = metrics.sleepDurationMinutes else {
            return UserAnalysisAdvice(
                title: "Добавь сон",
                message: "Заполни дневник сна — без него оценка ресурса остаётся предварительной.",
                sfSymbol: "bed.double.fill",
                priority: .medium
            )
        }
        guard sleepMinutes < metrics.recommendedSleepRangeMinutes.lowerBound else { return nil }

        let hour = calendar.component(.hour, from: date)
        let action = hour < 12
            ? "Сложную работу лучше сделать раньше и оставить паузы."
            : "На оставшуюся часть дня сократи сложные задачи и оставь паузы."
        return UserAnalysisAdvice(
            title: "Сон снижает ресурс",
            message: "Последний сон — \(durationText(sleepMinutes)). \(action)",
            sfSymbol: "moon.zzz.fill",
            priority: .high
        )
    }

    private func loadAdvice(
        metrics: UserAnalysisMetrics,
        loadScore: Int,
        tasks: [TaskItem]
    ) -> UserAnalysisAdvice? {
        if loadScore >= 78 {
            return UserAnalysisAdvice(
                title: "План больше доступного времени",
                message: overloadMessage(metrics: metrics, tasks: tasks),
                sfSymbol: "exclamationmark.triangle.fill",
                priority: .high
            )
        }
        guard loadScore >= 58 else { return nil }
        return UserAnalysisAdvice(
            title: "Нагрузка высокая",
            message: "Доступно около \(durationText(metrics.availableFocusMinutes)), а задач осталось на \(durationText(metrics.remainingEstimatedMinutes)). Не добавляй новые дела до завершения главных.",
            sfSymbol: "target",
            priority: .medium
        )
    }

    private func overloadMessage(metrics: UserAnalysisMetrics, tasks: [TaskItem]) -> String {
        let flexibleTasks = tasks.filter { $0.source != .calendar }
        let keep = flexibleTasks.max {
            ($0.importance, $0.difficulty) < ($1.importance, $1.difficulty)
        }
        let movable = flexibleTasks
            .filter { $0.id != keep?.id }
            .min {
                ($0.importance, -Int($0.estimatedDuration))
                    < ($1.importance, -Int($1.estimatedDuration))
            }

        if let keep, let movable {
            return "Доступно \(durationText(metrics.availableFocusMinutes)), план занимает \(durationText(metrics.remainingEstimatedMinutes)). Оставь «\(keep.name)», а «\(movable.name)» перенеси на другой день."
        }
        if let task = keep {
            return "На «\(task.name)» запланировано больше доступного времени. Разбей задачу на шаг до \(durationText(metrics.availableFocusMinutes)) и продолжение."
        }
        return "На задачи нужно больше доступного времени. Освободи один блок или перенеси наименее важное дело."
    }

    private func overdueAdvice(
        metrics: UserAnalysisMetrics,
        tasks: [TaskItem],
        date: Date
    ) -> UserAnalysisAdvice? {
        guard metrics.overdueTaskCount > 0,
              let task = tasks.first(where: { $0.deadlineDate < date }) else { return nil }
        return UserAnalysisAdvice(
            title: "Есть просроченная задача",
            message: "«\(task.name)» уже вышла за дедлайн. Перенеси её осознанно или закрой следующим фокус-блоком.",
            sfSymbol: "clock.badge.exclamationmark.fill",
            priority: .high
        )
    }

    private func tomorrowAdvice(
        metrics: UserAnalysisMetrics,
        tasks: [TaskItem]
    ) -> UserAnalysisAdvice? {
        guard metrics.tomorrowWorkloadScore >= 65 || metrics.tomorrowTaskCount >= 7 else { return nil }
        let mainTask = tasks.max { $0.importance < $1.importance }
        let detail = mainTask.map { " Главная — «\($0.name)»." } ?? ""
        return UserAnalysisAdvice(
            title: "Завтра высокая нагрузка",
            message: "На завтра уже \(metrics.tomorrowTaskCount) задач.\(detail) Сегодня не добавляй новые дела и оставь время на восстановление.",
            sfSymbol: "calendar.badge.exclamationmark",
            priority: .high
        )
    }

    private func emotionAdvice(
        metrics: UserAnalysisMetrics,
        readinessScore: Int
    ) -> UserAnalysisAdvice? {
        if metrics.emotionBalance == nil {
            return UserAnalysisAdvice(
                title: "Отметь эмоции",
                message: "Короткая запись повысит точность анализа и поможет заметить влияние нагрузки.",
                sfSymbol: "face.smiling.fill",
                priority: .info
            )
        }
        if metrics.emotionalStrain >= 0.45 {
            return UserAnalysisAdvice(
                title: "Есть эмоциональное напряжение",
                message: "Сильная напряжённая эмоция не потерялась среди других записей. Снизь планку на оставшийся день и оставь место для восстановления.",
                sfSymbol: "heart.text.square.fill",
                priority: .medium
            )
        }
        guard metrics.emotionalSupport >= 0.45, readinessScore >= 60 else { return nil }
        return UserAnalysisAdvice(
            title: "Есть ресурс для важного",
            message: "Эмоциональный фон поддерживает работу. Используй окно для одной важной задачи.",
            sfSymbol: "sparkles",
            priority: .info
        )
    }

    private func durationText(_ minutes: Int) -> String {
        let hours = minutes / 60
        let restMinutes = minutes % 60
        return "\(hours)ч \(restMinutes)м"
    }
}
