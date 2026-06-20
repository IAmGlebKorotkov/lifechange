//
//  AchievementService.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 19.06.2026.
//

import Foundation

final class AchievementService {

    private let repository: AchievementRepositoryProtocol

    init(repository: AchievementRepositoryProtocol = AchievementRepository()) {
        self.repository = repository
    }

    func fetchAchievements(forUserID userID: UUID) throws -> [AchievementItem] {
        try repository.fetchAchievements(forUserID: userID)
    }

    @discardableResult
    func markOpened(achievementID: UUID, forUserID userID: UUID) throws -> AchievementItem {
        try repository.markOpened(achievementID: achievementID, forUserID: userID)
    }

    func recordFocusSession(
        forUserID userID: UUID,
        taskID: UUID?,
        startedAt: Date,
        endedAt: Date
    ) throws {
        try repository.recordFocusSession(
            forUserID: userID,
            taskID: taskID,
            startedAt: startedAt,
            endedAt: endedAt
        )
    }
}
