//
//  DiaryEntry.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 08.05.2026.
//

import Foundation

extension Notification.Name {
    static let diaryStoreDidChange = Notification.Name("diaryStoreDidChange")
}

enum EmotionKind: String, CaseIterable {
    case joy = "Радость"
    case sadness = "Грусть"
    case anger = "Злость"
    case anxiety = "Тревога"
    case calm = "Покой"
    case love = "Любовь"

    var valence: Double {
        switch self {
        case .joy, .calm, .love:
            return 1
        case .sadness, .anger, .anxiety:
            return -1
        }
    }
}

struct EmotionDiaryInput: Equatable {
    let emotionName: String
    let sfSymbol: String
    let reason: String?
    let intensity: Int
}

struct EmotionDiaryEntry: Equatable {
    let id: UUID
    let emotionName: String
    let sfSymbol: String
    let reason: String?
    let intensity: Int
    let dayDate: Date
    let createdAt: Date
    let ownerId: UUID
}

struct SleepDiaryEntry: Equatable {
    let id: UUID
    let dayDate: Date
    let bedtime: Date
    let wakeTime: Date
    let durationMinutes: Int
    let createdAt: Date
    let ownerId: UUID
}
