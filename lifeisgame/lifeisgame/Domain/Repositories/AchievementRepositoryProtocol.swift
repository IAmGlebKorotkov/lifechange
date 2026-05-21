//
//  AchievementRepositoryProtocol.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 19.05.2026.
//

import Foundation

protocol AchievementRepositoryProtocol {
    func fetchAchievements(forUserID userID: UUID) throws -> [AchievementItem]

    @discardableResult
    func markOpened(achievementID: UUID, forUserID userID: UUID) throws -> AchievementItem

    func recordFocusSession(forUserID userID: UUID, taskID: UUID?, startedAt: Date, endedAt: Date) throws
}
