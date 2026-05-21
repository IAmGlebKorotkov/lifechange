//
//  MLCoreUserAnalysisEngineTests.swift
//  lifeisgameTests
//
//  Created by Codex on 19.05.2026.
//

import XCTest
@testable import lifeisgame

final class MLCoreUserAnalysisEngineTests: XCTestCase {

    private let calendar = Calendar(identifier: .gregorian)

    func testAnalyzeWarnsWhenSleepIsShortAndTomorrowIsHeavy() {
        let date = calendar.date(from: DateComponents(year: 2026, month: 5, day: 19, hour: 9))!
        let engine = MLCoreUserAnalysisEngine(calendar: calendar)
        let input = UserAnalysisInput(
            user: makeUser(on: date),
            date: date,
            todayTasks: [
                makeTask(name: "Сложная задача", date: date, difficulty: 9, importance: 9, durationHours: 3)
            ],
            tomorrowTasks: (0..<8).map {
                makeTask(name: "Задача \($0)", date: calendar.date(byAdding: .day, value: 1, to: date)!, difficulty: 7, importance: 7, durationHours: 1)
            },
            emotionEntries: [
                makeEmotion(name: "Тревога", intensity: 8, date: date)
            ],
            sleepEntries: [
                makeSleep(minutes: 5 * 60 + 20, date: date)
            ]
        )

        let result = engine.analyze(input: input)

        XCTAssertLessThan(result.readinessScore, 60)
        XCTAssertTrue(result.advices.contains { $0.title == "Сон снижает ресурс" })
        XCTAssertTrue(result.advices.contains { $0.title == "Завтра высокая нагрузка" })
        XCTAssertEqual(result.metrics.tomorrowTaskCount, 8)
    }

    func testAnalyzeKeepsBalancedDayWhenSleepAndLoadAreOk() {
        let date = calendar.date(from: DateComponents(year: 2026, month: 5, day: 19, hour: 9))!
        let engine = MLCoreUserAnalysisEngine(calendar: calendar)
        let input = UserAnalysisInput(
            user: makeUser(on: date),
            date: date,
            todayTasks: [
                makeTask(name: "Почта", date: date, difficulty: 3, importance: 4, durationHours: 1),
                makeTask(name: "План", date: date, difficulty: 4, importance: 5, durationHours: 1.5)
            ],
            tomorrowTasks: [],
            emotionEntries: [
                makeEmotion(name: "Покой", intensity: 7, date: date)
            ],
            sleepEntries: [
                makeSleep(minutes: 8 * 60, date: date)
            ]
        )

        let result = engine.analyze(input: input)

        XCTAssertGreaterThanOrEqual(result.readinessScore, 70)
        XCTAssertEqual(result.workloadLevel, .balanced)
        XCTAssertTrue(result.advices.contains { $0.title == "Хорошее окно для сложного" })
    }

    private func makeUser(on date: Date) -> User {
        User(
            id: UUID(),
            name: "Test",
            email: "test@example.com",
            birthDate: calendar.date(byAdding: .year, value: -25, to: date),
            createdAt: date
        )
    }

    private func makeTask(name: String,
                          date: Date,
                          difficulty: Int,
                          importance: Int,
                          durationHours: TimeInterval) -> TaskItem {
        let startDate = calendar.date(bySettingHour: 10, minute: 0, second: 0, of: date)!
        let deadlineDate = startDate.addingTimeInterval(durationHours * 3600)
        return TaskItem(
            id: UUID(),
            name: name,
            taskDescription: nil,
            startDate: startDate,
            deadlineDate: deadlineDate,
            isCompleted: false,
            isHardTask: difficulty >= 7,
            planningStartDate: startDate,
            planningDeadlineDate: deadlineDate,
            importance: importance,
            difficulty: difficulty,
            estimatedDuration: durationHours * 3600,
            createdAt: date,
            ownerId: UUID(),
            parentTaskId: nil,
            subtasks: [],
            source: .app
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

    private func makeSleep(minutes: Int, date: Date) -> SleepDiaryEntry {
        let bedtime = calendar.date(bySettingHour: 23, minute: 0, second: 0, of: date)!
        let wakeTime = bedtime.addingTimeInterval(TimeInterval(minutes * 60))
        return SleepDiaryEntry(
            id: UUID(),
            dayDate: calendar.startOfDay(for: date),
            bedtime: bedtime,
            wakeTime: wakeTime,
            durationMinutes: minutes,
            createdAt: date,
            ownerId: UUID()
        )
    }
}
