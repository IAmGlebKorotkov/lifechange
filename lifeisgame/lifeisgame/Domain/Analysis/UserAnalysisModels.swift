//
//  UserAnalysisModels.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 12.05.2026.
//

import Foundation

enum SleepRecommendation {
    static func rangeMinutes(forAge age: Int?) -> ClosedRange<Int> {
        guard let age else { return (7 * 60)...(9 * 60) }

        switch age {
        case 0:
            return (12 * 60)...(16 * 60)
        case 1...2:
            return (11 * 60)...(14 * 60)
        case 3...5:
            return (10 * 60)...(13 * 60)
        case 6...12:
            return (9 * 60)...(12 * 60)
        case 13...17:
            return (8 * 60)...(10 * 60)
        case 61...64:
            return (7 * 60)...(9 * 60)
        case 65...:
            return (7 * 60)...(8 * 60)
        default:
            return (7 * 60)...(9 * 60)
        }
    }
}

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

enum UserAnalysisConfidenceLevel: Equatable {
    case low
    case medium
    case high

    var title: String {
        switch self {
        case .low:
            return "низкая"
        case .medium:
            return "средняя"
        case .high:
            return "высокая"
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
    let completedTaskCount: Int
    let todayHardTaskCount: Int
    let tomorrowTaskCount: Int
    let tomorrowHardTaskCount: Int
    let averageDifficulty: Double
    let completedEstimatedMinutes: Int
    let remainingEstimatedMinutes: Int
    let availableFocusMinutes: Int
    let fixedEventMinutes: Int
    let overdueTaskCount: Int
    let averageSleepMinutes: Int?
    let sleepScheduleVariationMinutes: Int?
    let todayWorkloadScore: Double
    let tomorrowWorkloadScore: Double
    let emotionBalance: Double?
    let emotionalStrain: Double
    let emotionalSupport: Double
}

struct UserAnalysisResult: Equatable {
    let readinessScore: Int
    let resourceScore: Int
    let loadScore: Int
    let balanceScore: Int
    let confidenceScore: Int
    let confidenceLevel: UserAnalysisConfidenceLevel
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

struct GeneralWeeklyStats: Equatable {
    let completedTasks: Int
    let totalTasks: Int
    let sleepQuality: Double
    let efficiency: Double
    let mood: Double

    static let empty = GeneralWeeklyStats(
        completedTasks: 0,
        totalTasks: 0,
        sleepQuality: 0,
        efficiency: 0,
        mood: 0
    )
}
