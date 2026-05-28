//
//  UserAnalysisModels.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 19.05.2026.
//

import Foundation

enum UserAdvicePriority: Int, Equatable {
    case info
    case medium
    case high
}

enum UserWorkloadLevel: Equatable {
    case low
    case balanced
    case high
    case overloaded

    var title: String {
        switch self {
        case .low:
            return "Легкий день"
        case .balanced:
            return "Сбалансированный день"
        case .high:
            return "Высокая нагрузка"
        case .overloaded:
            return "Перегруз"
        }
    }
}

struct UserAnalysisAdvice: Equatable {
    let title: String
    let message: String
    let sfSymbol: String
    let priority: UserAdvicePriority
}

struct UserAnalysisMetrics: Equatable {
    let age: Int?
    let sleepDurationMinutes: Int?
    let recommendedSleepRangeMinutes: ClosedRange<Int>
    let todayTaskCount: Int
    let todayHardTaskCount: Int
    let tomorrowTaskCount: Int
    let tomorrowHardTaskCount: Int
    let averageDifficulty: Double
    let todayWorkloadScore: Double
    let tomorrowWorkloadScore: Double
    let emotionBalance: Double?
}

struct UserAnalysisResult: Equatable {
    let readinessScore: Int
    let workloadLevel: UserWorkloadLevel
    let summary: String
    let signals: [String]
    let advices: [UserAnalysisAdvice]
    let metrics: UserAnalysisMetrics
}

struct UserAnalysisInput: Equatable {
    let user: User
    let date: Date
    let todayTasks: [TaskItem]
    let tomorrowTasks: [TaskItem]
    let emotionEntries: [EmotionDiaryEntry]
    let sleepEntries: [SleepDiaryEntry]
}
