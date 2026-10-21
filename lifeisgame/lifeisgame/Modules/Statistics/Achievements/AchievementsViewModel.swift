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
    @Published var errorMessage: String?

    private let achievementService: AchievementService
    private var observerTokens: [NSObjectProtocol] = []
    private var reloadWorkItem: DispatchWorkItem?

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
            errorMessage = error.localizedDescription
        }
    }

    func openAchievement(_ item: AchievementItem) {
        guard item.state == .unlocked else { return }

        guard let userID = SessionManager.shared.currentUserID else {
            errorMessage = "Активная сессия не найдена"
            return
        }
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }

        do {
            items[index] = try achievementService.markOpened(achievementID: item.id, forUserID: userID)
        } catch {
            errorMessage = error.localizedDescription
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
                self?.scheduleReload()
            }
        }
    }

    /// Дебаунс: изменение данных шлёт серию нотификаций,
    /// без коалесации экран перечитывал бы Core Data по несколько раз подряд.
    private func scheduleReload() {
        reloadWorkItem?.cancel()
        let workItem = DispatchWorkItem { [weak self] in
            self?.loadAchievements()
        }
        reloadWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: workItem)
    }
}
