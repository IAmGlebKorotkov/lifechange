//
//  DiaryRepositoryProtocol.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 08.05.2026.
//

import Foundation

protocol DiaryRepositoryProtocol {
    @discardableResult
    func saveEmotionEntries(_ entries: [EmotionDiaryInput], forUserID userID: UUID, on date: Date) throws -> [EmotionDiaryEntry]

    @discardableResult
    func saveSleepEntry(bedtime: Date, wakeTime: Date, forUserID userID: UUID, on date: Date) throws -> SleepDiaryEntry

    func fetchEmotionEntries(forUserID userID: UUID) throws -> [EmotionDiaryEntry]
    func fetchSleepEntries(forUserID userID: UUID) throws -> [SleepDiaryEntry]
    func hasEmotionEntry(forUserID userID: UUID, on date: Date) throws -> Bool
    func hasSleepEntry(forUserID userID: UUID, on date: Date) throws -> Bool
}
