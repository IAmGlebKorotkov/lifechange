//
//  DiaryService.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 19.06.2026.
//

import Foundation

final class DiaryService {

    private let repository: DiaryRepositoryProtocol

    init(repository: DiaryRepositoryProtocol = DiaryRepository()) {
        self.repository = repository
    }

    @discardableResult
    func saveEmotionEntries(
        _ entries: [EmotionDiaryInput],
        forUserID userID: UUID,
        on date: Date
    ) throws -> [EmotionDiaryEntry] {
        try repository.saveEmotionEntries(entries, forUserID: userID, on: date)
    }

    @discardableResult
    func saveSleepEntry(
        bedtime: Date,
        wakeTime: Date,
        forUserID userID: UUID,
        on date: Date
    ) throws -> SleepDiaryEntry {
        try repository.saveSleepEntry(bedtime: bedtime, wakeTime: wakeTime, forUserID: userID, on: date)
    }

    func fetchEmotionEntries(forUserID userID: UUID) throws -> [EmotionDiaryEntry] {
        try repository.fetchEmotionEntries(forUserID: userID)
    }

    func fetchSleepEntries(forUserID userID: UUID) throws -> [SleepDiaryEntry] {
        try repository.fetchSleepEntries(forUserID: userID)
    }

    func hasEmotionEntry(forUserID userID: UUID, on date: Date) throws -> Bool {
        try repository.hasEmotionEntry(forUserID: userID, on: date)
    }

    func hasSleepEntry(forUserID userID: UUID, on date: Date) throws -> Bool {
        try repository.hasSleepEntry(forUserID: userID, on: date)
    }
}
