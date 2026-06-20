//
//  AchievementsViewModel.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 21.05.2026.
//

import Combine
import Foundation

final class AchievementsViewModel: ObservableObject {

    @Published private(set) var items: [AchievementItem] = []

    private let achievementService: AchievementService
    private var observerTokens: [NSObjectProtocol] = []

    init(achievementService: AchievementService) {
        self.achievementService = achievementService
        observeStoreChanges()
    }

    deinit {
        observerTokens.forEach(NotificationCenter.default.removeObserver)
    }

    func loadAchievements() {
        guard let userID = SessionManager.shared.currentUserID else {
            items = []
            return
        }

        do {
            items = try achievementService.fetchAchievements(forUserID: userID)
        } catch {
            items = []
        }
    }

    func openAchievement(_ item: AchievementItem) {
        guard item.state == .unlocked,
              let userID = SessionManager.shared.currentUserID,
              let index = items.firstIndex(where: { $0.id == item.id }) else { return }

        do {
            items[index] = try achievementService.markOpened(achievementID: item.id, forUserID: userID)
        } catch {
            loadAchievements()
        }
    }

    private func observeStoreChanges() {
        let names: [Notification.Name] = [
            .taskStoreDidChange,
            .diaryStoreDidChange,
            .focusSessionStoreDidChange,
            .achievementStoreDidChange
        ]

        observerTokens = names.map { name in
            NotificationCenter.default.addObserver(
                forName: name,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                self?.loadAchievements()
            }
        }
    }
}
