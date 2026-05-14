//
//  CreateTaskUseCase.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.04.2026.
//

import Foundation

final class CreateTaskUseCase {

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

    private let repository: TaskRepositoryProtocol
    private let calendarService: CalendarServiceProtocol

    init(repository: TaskRepositoryProtocol, calendarService: CalendarServiceProtocol) {
        self.repository = repository
        self.calendarService = calendarService
    }

    func execute(input: Input, userID: UUID, completion: @escaping (Result<TaskItem, Error>) -> Void) {
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
}

private struct ScheduleInterval {
    let start: Date
    let end: Date
}

private struct PlannedSubtask {
    let subtask: CreateTaskUseCase.SubtaskInput
    let start: Date
    let end: Date
}

private enum TaskScheduleHelpers {
    static let minimumDuration: TimeInterval = 15 * 60

    static func urgency(importance: Int, difficulty: Int) -> Double {
        let importance = Double(max(1, min(10, importance))) / 10
        let difficulty = Double(max(1, min(10, difficulty))) / 10
        return importance * 0.65 + difficulty * 0.35
    }

    static func busyIntervals(from tasks: [TaskItem]) -> [ScheduleInterval] {
        tasks.flatMap { task -> [ScheduleInterval] in
            if task.isHardTask && !task.subtasks.isEmpty {
                return task.subtasks.map { ScheduleInterval(start: $0.startDate, end: $0.deadlineDate) }
            }
            return [ScheduleInterval(start: task.startDate, end: task.deadlineDate)]
        }
    }

    static func workSegments(from planningStart: Date, to planningDeadline: Date) -> [ScheduleInterval] {
        let calendar = Calendar.current
        var result: [ScheduleInterval] = []
        var day = calendar.startOfDay(for: planningStart)
        let lastDay = calendar.startOfDay(for: planningDeadline)

        while day <= lastDay {
            let dayStart = max(calendar.date(bySettingHour: 8, minute: 0, second: 0, of: day) ?? day, planningStart)
            let dayEnd = min(calendar.date(bySettingHour: 23, minute: 0, second: 0, of: day) ?? day, planningDeadline)
            if dayEnd > dayStart {
                result.append(ScheduleInterval(start: dayStart, end: dayEnd))
            }
            guard let nextDay = calendar.date(byAdding: .day, value: 1, to: day) else { break }
            day = nextDay
        }

        return result
    }

    static func date(at progress: Double, in segments: [ScheduleInterval]) -> Date? {
        let total = segments.reduce(0) { $0 + $1.end.timeIntervalSince($1.start) }
        guard total > 0 else { return segments.first?.start }

        var remaining = max(0, min(1, progress)) * total
        for segment in segments {
            let length = segment.end.timeIntervalSince(segment.start)
            if remaining <= length {
                return segment.start.addingTimeInterval(remaining)
            }
            remaining -= length
        }
        return segments.last?.end
    }

    static func progress(of date: Date, in segments: [ScheduleInterval]) -> Double {
        let total = segments.reduce(0) { $0 + $1.end.timeIntervalSince($1.start) }
        guard total > 0 else { return 0 }

        var elapsed: TimeInterval = 0
        for segment in segments {
            if date >= segment.end {
                elapsed += segment.end.timeIntervalSince(segment.start)
            } else if date > segment.start {
                elapsed += date.timeIntervalSince(segment.start)
                break
            } else {
                break
            }
        }
        return max(0, min(1, elapsed / total))
    }

    static func freeGaps(in segment: ScheduleInterval, busyIntervals: [ScheduleInterval]) -> [ScheduleInterval] {
        let busy = busyIntervals
            .filter { $0.start < segment.end && $0.end > segment.start }
            .map { ScheduleInterval(start: max($0.start, segment.start), end: min($0.end, segment.end)) }
            .sorted { $0.start < $1.start }

        var cursor = segment.start
        var gaps: [ScheduleInterval] = []
        for interval in busy {
            if interval.start > cursor {
                gaps.append(ScheduleInterval(start: cursor, end: interval.start))
            }
            cursor = max(cursor, interval.end)
        }
        if cursor < segment.end {
            gaps.append(ScheduleInterval(start: cursor, end: segment.end))
        }
        return gaps
    }

    static func candidateStarts(target: Date, duration: TimeInterval, in gap: ScheduleInterval) -> [Date] {
        let latestStart = gap.end.addingTimeInterval(-duration)
        guard latestStart >= gap.start else { return [] }

        let centered = target.addingTimeInterval(-duration / 2)
        let boundedCenter = min(max(centered, gap.start), latestStart)
        let midpoint = gap.start.addingTimeInterval((gap.end.timeIntervalSince(gap.start) - duration) / 2)
        return [gap.start, boundedCenter, midpoint, latestStart]
    }

    static func nextNonOverlappingStart(
        from requestedStart: Date,
        duration: TimeInterval,
        busyIntervals: [ScheduleInterval]
    ) -> Date {
        let intervals = busyIntervals.sorted { $0.start < $1.start }
        var cursor = requestedStart

        for interval in intervals {
            let candidateEnd = cursor.addingTimeInterval(duration)
            if candidateEnd <= interval.start {
                break
            }
            if cursor < interval.end && candidateEnd > interval.start {
                cursor = interval.end
            }
        }
        return cursor
    }
}

private enum SubtaskAutoScheduler {

    private struct Candidate {
        let start: Date
        let end: Date
        let score: Double
    }

    private struct WorkItem {
        let index: Int
        let subtask: CreateTaskUseCase.SubtaskInput
        let duration: TimeInterval
        let urgency: Double
        let target: Date
    }

    static func schedule(input: CreateTaskUseCase.Input, existingTasks: [TaskItem]) -> [PlannedSubtask] {
        let calendar = Calendar.current
        let planningStart = calendar.startOfDay(for: input.startDate)
        let planningDeadline = calendar.endOfDay(for: input.deadlineDate)
        let segments = TaskScheduleHelpers.workSegments(from: planningStart, to: planningDeadline)
        guard !segments.isEmpty, !input.subtasks.isEmpty else { return [] }

        let urgencies = input.subtasks.map {
            TaskScheduleHelpers.urgency(importance: $0.importance, difficulty: $0.difficulty)
        }
        let averageUrgency = urgencies.reduce(0, +) / Double(max(1, urgencies.count))

        let items = input.subtasks.enumerated().compactMap { index, subtask -> WorkItem? in
            let baseProgress = Double(index + 1) / Double(input.subtasks.count + 1)
            let urgencyShift = (urgencies[index] - averageUrgency) * 0.22
            let targetProgress = max(0.05, min(0.95, baseProgress - urgencyShift))
            guard let target = TaskScheduleHelpers.date(at: targetProgress, in: segments) else { return nil }
            return WorkItem(
                index: index,
                subtask: subtask,
                duration: max(TaskScheduleHelpers.minimumDuration, subtask.estimatedDuration),
                urgency: urgencies[index],
                target: target
            )
        }
        .sorted {
            if $0.target == $1.target { return $0.urgency > $1.urgency }
            return $0.target < $1.target
        }

        var busyIntervals = TaskScheduleHelpers.busyIntervals(from: existingTasks)
        var plans: [(index: Int, plan: PlannedSubtask)] = []

        for item in items {
            let candidate = bestCandidate(for: item, segments: segments, busyIntervals: busyIntervals)
            let start = candidate?.start ?? fallbackStart(for: item, segments: segments, busyIntervals: busyIntervals)
            let end = start.addingTimeInterval(item.duration)
            busyIntervals.append(ScheduleInterval(start: start, end: end))
            plans.append((
                index: item.index,
                plan: PlannedSubtask(subtask: item.subtask, start: start, end: end)
            ))
        }

        return plans
            .map(\.plan)
            .sorted { $0.start < $1.start }
    }

    private static func bestCandidate(
        for item: WorkItem,
        segments: [ScheduleInterval],
        busyIntervals: [ScheduleInterval]
    ) -> Candidate? {
        var candidates: [Candidate] = []
        let timeline = max(1, segments.last?.end.timeIntervalSince(segments.first?.start ?? item.target) ?? 1)

        for segment in segments {
            let gaps = TaskScheduleHelpers.freeGaps(in: segment, busyIntervals: busyIntervals)
            for gap in gaps where gap.end.timeIntervalSince(gap.start) >= item.duration {
                for start in TaskScheduleHelpers.candidateStarts(target: item.target, duration: item.duration, in: gap) {
                    let end = start.addingTimeInterval(item.duration)
                    let midpoint = start.addingTimeInterval(item.duration / 2)
                    let targetDistance = abs(midpoint.timeIntervalSince(item.target)) / timeline
                    let targetScore = (1 - min(1, targetDistance)) * 65
                    let earlyProgress = 1 - TaskScheduleHelpers.progress(of: start, in: segments)
                    let earlyScore = earlyProgress * item.urgency * 20
                    let hour = Double(Calendar.current.component(.hour, from: start))
                        + Double(Calendar.current.component(.minute, from: start)) / 60
                    let morningFit = max(0, 1 - abs(hour - 10) / 12)
                    let difficulty = Double(max(1, min(10, item.subtask.difficulty))) / 10
                    let gapFit = min(1, gap.end.timeIntervalSince(gap.start) / max(item.duration, 1)) * 5
                    let score = targetScore + earlyScore + morningFit * difficulty * 10 + gapFit
                    candidates.append(Candidate(start: start, end: end, score: score))
                }
            }
        }

        return candidates.max { $0.score < $1.score }
    }

    private static func fallbackStart(
        for item: WorkItem,
        segments: [ScheduleInterval],
        busyIntervals: [ScheduleInterval]
    ) -> Date {
        let firstStart = segments.first?.start ?? item.target
        let lastEnd = segments.last?.end ?? item.target
        let requested = min(max(item.target.addingTimeInterval(-item.duration / 2), firstStart), lastEnd)
        return TaskScheduleHelpers.nextNonOverlappingStart(
            from: requested,
            duration: item.duration,
            busyIntervals: busyIntervals
        )
    }
}

private enum TaskAutoScheduler {

    private struct Candidate {
        let start: Date
        let end: Date
        let score: Double
    }

    static func schedule(input: CreateTaskUseCase.Input, existingTasks: [TaskItem]) -> (start: Date, end: Date) {
        let calendar = Calendar.current
        let planningStart = calendar.startOfDay(for: input.startDate)
        let planningDeadline = calendar.endOfDay(for: input.deadlineDate)
        let duration = max(15 * 60, input.estimatedDuration)
        let importance = Double(max(1, min(10, input.importance))) / 10
        let difficulty = Double(max(1, min(10, input.difficulty))) / 10
        let urgency = importance * 0.65 + difficulty * 0.35
        let busySource = TaskScheduleHelpers.busyIntervals(from: existingTasks)

        var candidates: [Candidate] = []
        var day = planningStart
        let totalDays = max(1, calendar.dateComponents([.day], from: planningStart, to: planningDeadline).day ?? 1)

        while day <= planningDeadline {
            let dayStart = max(calendar.date(bySettingHour: 8, minute: 0, second: 0, of: day) ?? day, planningStart)
            let dayEnd = min(calendar.date(bySettingHour: 23, minute: 0, second: 0, of: day) ?? day, planningDeadline)
            let workingSeconds = max(0, dayEnd.timeIntervalSince(dayStart))

            if workingSeconds >= duration {
                let busyIntervals = busySource
                    .filter { $0.start < dayEnd && $0.end > dayStart }
                    .map { (start: max($0.start, dayStart), end: min($0.end, dayEnd)) }
                    .sorted { $0.start < $1.start }

                let busySeconds = busyIntervals.reduce(0) { total, interval in
                    total + max(0, interval.end.timeIntervalSince(interval.start))
                }
                let congestion = min(1, busySeconds / workingSeconds)
                var cursor = dayStart

                for interval in busyIntervals {
                    appendCandidate(
                        from: cursor,
                        to: interval.start,
                        duration: duration,
                        dayStart: dayStart,
                        dayEnd: dayEnd,
                        planningStart: planningStart,
                        totalDays: totalDays,
                        congestion: congestion,
                        urgency: urgency,
                        difficulty: difficulty,
                        into: &candidates
                    )
                    cursor = max(cursor, interval.end)
                }

                appendCandidate(
                    from: cursor,
                    to: dayEnd,
                    duration: duration,
                    dayStart: dayStart,
                    dayEnd: dayEnd,
                    planningStart: planningStart,
                    totalDays: totalDays,
                    congestion: congestion,
                    urgency: urgency,
                    difficulty: difficulty,
                    into: &candidates
                )
            }

            guard let nextDay = calendar.date(byAdding: .day, value: 1, to: day) else { break }
            day = nextDay
        }

        if let best = candidates.max(by: { $0.score < $1.score }) {
            return (best.start, best.end)
        }

        let fallbackAnchor = calendar.date(bySettingHour: 8, minute: 0, second: 0, of: planningStart) ?? planningStart
        let fallbackStart = nextNonOverlappingStart(
            from: fallbackAnchor,
            duration: duration,
            busyIntervals: busySource
        )
        return (fallbackStart, fallbackStart.addingTimeInterval(duration))
    }

    private static func appendCandidate(
        from gapStart: Date,
        to gapEnd: Date,
        duration: TimeInterval,
        dayStart: Date,
        dayEnd: Date,
        planningStart: Date,
        totalDays: Int,
        congestion: TimeInterval,
        urgency: Double,
        difficulty: Double,
        into candidates: inout [Candidate]
    ) {
        guard gapEnd.timeIntervalSince(gapStart) >= duration else { return }

        let start = gapStart
        let end = start.addingTimeInterval(duration)
        let calendar = Calendar.current
        let dayIndex = max(0, calendar.dateComponents([.day], from: planningStart, to: dayStart).day ?? 0)
        let earlyScore = 1 - (Double(dayIndex) / Double(totalDays))
        let hour = Double(calendar.component(.hour, from: start)) + Double(calendar.component(.minute, from: start)) / 60
        let morningFit = max(0, 1 - abs(hour - 10) / 12)
        let gapFit = min(1, gapEnd.timeIntervalSince(gapStart) / max(duration, 1))

        let score = (1 - congestion) * 45
            + earlyScore * urgency * 35
            + morningFit * difficulty * 15
            + gapFit * 5

        candidates.append(Candidate(start: start, end: end, score: score))
    }

    private static func nextNonOverlappingStart(
        from requestedStart: Date,
        duration: TimeInterval,
        busyIntervals: [ScheduleInterval]
    ) -> Date {
        let intervals = busyIntervals.sorted { $0.start < $1.start }

        var cursor = requestedStart
        for interval in intervals {
            let candidateEnd = cursor.addingTimeInterval(duration)
            if candidateEnd <= interval.start {
                break
            }
            if cursor < interval.end && candidateEnd > interval.start {
                cursor = interval.end
            }
        }
        return cursor
    }
}

private extension Calendar {
    func endOfDay(for date: Date) -> Date {
        let start = startOfDay(for: date)
        return self.date(byAdding: DateComponents(day: 1, second: -1), to: start) ?? date
    }
}
