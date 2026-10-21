//
//  UserAnalysisEngineTests.swift
//  lifeisgameTests
//

import XCTest
import UIKit
@testable import lifeisgame

@MainActor
final class UserAnalysisEngineTests: XCTestCase {

    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current
        return calendar
    }

    func testEmptyInputProducesLowConfidencePreliminaryAnalysis() throws {
        let date = try makeDate(day: 6, hour: 9)
        let result = UserAnalysisEngine(calendar: calendar).analyze(
            input: makeInput(date: date)
        )

        XCTAssertEqual(result.confidenceLevel, .low)
        XCTAssertLessThan(result.confidenceScore, 45)
        XCTAssertLessThanOrEqual(result.resourceScore, 55)
        XCTAssertTrue(result.summary.contains("Предварительный"))
    }

    func testCompletedAndRemainingWorkAreReportedSeparately() throws {
        let date = try makeDate(day: 6, hour: 18)
        let completed = makeTask(
            name: "Подготовить отчёт",
            start: try makeDate(day: 6, hour: 9),
            durationMinutes: 180,
            difficulty: 8,
            importance: 9,
            isCompleted: true
        )
        let remaining = makeTask(
            name: "Ответить на письма",
            start: try makeDate(day: 6, hour: 19),
            durationMinutes: 60,
            difficulty: 3,
            importance: 4
        )
        let result = UserAnalysisEngine(calendar: calendar).analyze(
            input: makeInput(date: date, todayTasks: [completed, remaining])
        )

        XCTAssertEqual(result.metrics.completedTaskCount, 1)
        XCTAssertEqual(result.metrics.todayTaskCount, 1)
        XCTAssertEqual(result.metrics.completedEstimatedMinutes, 180)
        XCTAssertEqual(result.metrics.remainingEstimatedMinutes, 60)
        XCTAssertGreaterThan(result.loadScore, 0)
    }

    func testStrongDistressIsNotCancelledByPositiveEmotion() throws {
        let date = try makeDate(day: 6, hour: 18)
        let anxiety = makeEmotion(name: "Тревога", intensity: 10, date: date)
        let joy = makeEmotion(name: "Радость", intensity: 10, date: date)
        let mixed = UserAnalysisEngine(calendar: calendar).analyze(
            input: makeInput(date: date, emotions: [anxiety, joy])
        )
        let positiveOnly = UserAnalysisEngine(calendar: calendar).analyze(
            input: makeInput(date: date, emotions: [joy])
        )

        XCTAssertEqual(mixed.metrics.emotionalStrain, 1, accuracy: 0.01)
        XCTAssertEqual(mixed.metrics.emotionalSupport, 1, accuracy: 0.01)
        XCTAssertLessThan(mixed.resourceScore, positiveOnly.resourceScore)
    }

    func testOverloadAdviceNamesConcreteTaskToMove() throws {
        let date = try makeDate(day: 6, hour: 20)
        let essential = makeTask(
            name: "Подготовить презентацию",
            start: date,
            durationMinutes: 60,
            difficulty: 8,
            importance: 10
        )
        let movable = makeTask(
            name: "Разобрать почту",
            start: date,
            durationMinutes: 180,
            difficulty: 3,
            importance: 2
        )
        let result = UserAnalysisEngine(calendar: calendar).analyze(
            input: makeInput(date: date, todayTasks: [essential, movable])
        )

        XCTAssertEqual(result.metrics.availableFocusMinutes, 120)
        XCTAssertGreaterThanOrEqual(result.loadScore, 78)
        XCTAssertTrue(
            result.advices.contains(where: {
                $0.message.contains("Разобрать почту")
                    && $0.message.lowercased().contains("перенес")
            })
        )
    }

    func testResourceUsesSevenDaySleepTrend() throws {
        let date = try makeDate(day: 6, hour: 9)
        let entries = [
            makeSleep(day: 6, durationMinutes: 480),
            makeSleep(day: 5, durationMinutes: 360),
            makeSleep(day: 4, durationMinutes: 360)
        ]
        let result = UserAnalysisEngine(calendar: calendar).analyze(
            input: makeInput(date: date, sleep: entries)
        )
        let oneGoodNight = UserAnalysisEngine(calendar: calendar).analyze(
            input: makeInput(date: date, sleep: [entries[0]])
        )

        XCTAssertEqual(result.metrics.averageSleepMinutes, 400)
        XCTAssertLessThan(result.resourceScore, oneGoodNight.resourceScore)
        XCTAssertTrue(result.signals.contains(where: { $0.contains("Сон 7 дней") }))
    }

    func testAnalysisCardDisplaysDimensionsAndConfidence() throws {
        let date = try makeDate(day: 6, hour: 9)
        let result = UserAnalysisEngine(calendar: calendar).analyze(
            input: makeInput(
                date: date,
                emotions: [makeEmotion(name: "Покой", intensity: 7, date: date)],
                sleep: [makeSleep(day: 6, durationMinutes: 480)]
            )
        )
        let card = DayAnalysisTipsCardView()

        card.apply(result)

        let text = labels(in: card).compactMap(\.text).joined(separator: " ")
        let normalizedText = text.lowercased()
        XCTAssertTrue(normalizedText.contains("ресурс"))
        XCTAssertTrue(normalizedText.contains("нагрузка"))
        XCTAssertTrue(normalizedText.contains("баланс"))
        XCTAssertTrue(normalizedText.contains("точность"))
        XCTAssertFalse(text.contains(result.summary))
        XCTAssertEqual(
            views(in: card).compactMap { $0 as? AnalysisMiniMetricView }.count,
            3
        )
    }

    func testAnalysisCardInitiallyShowsOnlyTwoAdvices() throws {
        let date = try makeDate(day: 6, hour: 20)
        let overdue = makeTask(
            name: "Просроченная задача",
            start: try makeDate(day: 6, hour: 18),
            durationMinutes: 30,
            difficulty: 7,
            importance: 9
        )
        let remaining = makeTask(
            name: "Длинная задача",
            start: date,
            durationMinutes: 240,
            difficulty: 8,
            importance: 8
        )
        let tomorrowTasks = try (0..<7).map { index in
            makeTask(
                name: "Задача \(index)",
                start: try makeDate(day: 7, hour: 9 + index),
                durationMinutes: 60,
                difficulty: 7,
                importance: 7
            )
        }
        let result = UserAnalysisEngine(calendar: calendar).analyze(
            input: makeInput(
                date: date,
                todayTasks: [overdue, remaining],
                tomorrowTasks: tomorrowTasks
            )
        )
        let card = DayAnalysisTipsCardView()

        card.apply(result)

        XCTAssertGreaterThan(result.advices.count, 2)
        XCTAssertEqual(adviceRows(in: card).count, 2)
        let visibleMessages = labels(in: card).filter {
            $0.accessibilityIdentifier == "dayAnalysis.adviceMessage"
        }
        XCTAssertEqual(visibleMessages.count, 2)
        XCTAssertTrue(visibleMessages.allSatisfy { $0.numberOfLines == 0 })
        let showMoreButton = try XCTUnwrap(
            views(in: card).compactMap { $0 as? UIButton }.first {
                $0.accessibilityIdentifier == "dayAnalysis.showMore"
            }
        )

        showMoreButton.sendActions(for: .touchUpInside)

        XCTAssertEqual(adviceRows(in: card).count, result.advices.count)
    }

    func testCalendarEventReducesAvailableTimeButIsNotSuggestedForMoving() throws {
        let date = try makeDate(day: 6, hour: 18)
        let event = makeTask(
            name: "Встреча с врачом",
            start: try makeDate(day: 6, hour: 19),
            durationMinutes: 60,
            difficulty: 5,
            importance: 5,
            source: .calendar
        )
        let task = makeTask(
            name: "Большой рабочий блок",
            start: date,
            durationMinutes: 300,
            difficulty: 8,
            importance: 8
        )
        let result = UserAnalysisEngine(calendar: calendar).analyze(
            input: makeInput(date: date, todayTasks: [event, task])
        )

        XCTAssertEqual(result.metrics.fixedEventMinutes, 60)
        XCTAssertEqual(result.metrics.availableFocusMinutes, 180)
        XCTAssertFalse(
            result.advices.contains(where: {
                $0.message.contains("Встреча с врачом")
                    && $0.message.lowercased().contains("перенес")
            })
        )
    }

    func testSleepRecommendationsUseDetailedChildAndTeenAgeBands() throws {
        let date = try makeDate(day: 6, hour: 9)
        let childBirthDate = try XCTUnwrap(
            calendar.date(from: DateComponents(year: 2016, month: 8, day: 6))
        )
        let teenBirthDate = try XCTUnwrap(
            calendar.date(from: DateComponents(year: 2010, month: 8, day: 6))
        )
        let child = UserAnalysisEngine(calendar: calendar).analyze(
            input: makeInput(date: date, birthDate: childBirthDate)
        )
        let teen = UserAnalysisEngine(calendar: calendar).analyze(
            input: makeInput(date: date, birthDate: teenBirthDate)
        )

        XCTAssertEqual(child.metrics.recommendedSleepRangeMinutes, 540...720)
        XCTAssertEqual(teen.metrics.recommendedSleepRangeMinutes, 480...600)
    }

    func testOneLongSleepIsNotAutomaticallyPenalized() throws {
        let date = try makeDate(day: 6, hour: 9)
        let eightHours = UserAnalysisEngine(calendar: calendar).analyze(
            input: makeInput(date: date, sleep: [makeSleep(day: 6, durationMinutes: 480)])
        )
        let tenHours = UserAnalysisEngine(calendar: calendar).analyze(
            input: makeInput(date: date, sleep: [makeSleep(day: 6, durationMinutes: 600)])
        )

        XCTAssertEqual(tenHours.resourceScore, eightHours.resourceScore)
    }

    private func makeInput(
        date: Date,
        birthDate: Date? = nil,
        todayTasks: [TaskItem] = [],
        tomorrowTasks: [TaskItem] = [],
        emotions: [EmotionDiaryEntry] = [],
        sleep: [SleepDiaryEntry] = []
    ) -> UserAnalysisInput {
        UserAnalysisInput(
            user: User(
                id: UUID(),
                name: "Тест",
                email: "test@example.com",
                birthDate: birthDate,
                createdAt: date
            ),
            date: date,
            todayTasks: todayTasks,
            tomorrowTasks: tomorrowTasks,
            emotionEntries: emotions,
            sleepEntries: sleep
        )
    }

    private func makeTask(
        name: String,
        start: Date,
        durationMinutes: Int,
        difficulty: Int,
        importance: Int,
        isCompleted: Bool = false,
        source: TaskSource = .app
    ) -> TaskItem {
        TaskItem(
            id: UUID(),
            name: name,
            taskDescription: nil,
            startDate: start,
            deadlineDate: start.addingTimeInterval(TimeInterval(durationMinutes * 60)),
            isCompleted: isCompleted,
            isHardTask: false,
            planningStartDate: start,
            planningDeadlineDate: start,
            importance: importance,
            difficulty: difficulty,
            estimatedDuration: TimeInterval(durationMinutes * 60),
            createdAt: start,
            ownerId: UUID(),
            parentTaskId: nil,
            subtasks: [],
            source: source
        )
    }

    private func makeEmotion(name: String, intensity: Int, date: Date) -> EmotionDiaryEntry {
        EmotionDiaryEntry(
            id: UUID(),
            emotionName: name,
            sfSymbol: "circle",
            reason: nil,
            intensity: intensity,
            dayDate: calendar.startOfDay(for: date),
            createdAt: date,
            ownerId: UUID()
        )
    }

    private func makeSleep(day: Int, durationMinutes: Int) -> SleepDiaryEntry {
        let dayDate = calendar.date(
            from: DateComponents(year: 2026, month: 8, day: day, hour: 0)
        ) ?? Date(timeIntervalSince1970: 0)
        let bedtime = calendar.date(
            from: DateComponents(year: 2026, month: 8, day: day, hour: 23)
        ) ?? dayDate
        let wakeTime = bedtime.addingTimeInterval(TimeInterval(durationMinutes * 60))
        return SleepDiaryEntry(
            id: UUID(),
            dayDate: dayDate,
            bedtime: bedtime,
            wakeTime: wakeTime,
            durationMinutes: durationMinutes,
            createdAt: dayDate,
            ownerId: UUID()
        )
    }

    private func labels(in view: UIView) -> [UILabel] {
        view.subviews.flatMap { subview in
            (subview as? UILabel).map { [$0] } ?? []
                + labels(in: subview)
        }
    }

    private func views(in view: UIView) -> [UIView] {
        view.subviews.flatMap { [$0] + views(in: $0) }
    }

    private func adviceRows(in view: UIView) -> [UIView] {
        views(in: view).filter { $0.accessibilityIdentifier == "dayAnalysis.adviceRow" }
    }

    private func makeDate(day: Int, hour: Int) throws -> Date {
        try XCTUnwrap(
            calendar.date(from: DateComponents(year: 2026, month: 8, day: day, hour: hour))
        )
    }
}
