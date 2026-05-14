//
//  AppCoordinator.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.03.2026.
//

import UIKit

final class AppCoordinator: Coordinator {

    var childCoordinators: [Coordinator] = []
    private let window: UIWindow
    private let container = DIContainer()

    init(window: UIWindow) {
        self.window = window
    }

    func start() {
        if SessionManager.shared.canRestoreSessionWithoutAuth {
            showMain()
        } else if SessionManager.shared.canAttemptFaceIDUnlock {
            showFaceIDUnlock()
        } else {
            showAuth()
        }
    }

    func refreshNotificationsIfNeeded() {
        guard SessionManager.shared.canRestoreSessionWithoutAuth else { return }
        LocalNotificationService.shared.refreshDiaryReminders(repository: container.makeDiaryRepository())
    }

    private func showAuth() {
        let nav = UINavigationController()
        nav.setNavigationBarHidden(true, animated: false)
        window.rootViewController = nav

        let auth = AuthCoordinator(navigationController: nav, container: container)
        auth.onAuthCompleted = { [weak self, weak auth] in
            guard let self, let auth else { return }
            self.removeChild(auth)
            self.showMain()
        }
        addChild(auth)
    }

    private func showFaceIDUnlock() {
        let viewController = FaceIDUnlockViewController(userRepository: container.makeUserRepository())
        viewController.onUnlocked = { [weak self] in
            self?.showMain()
        }
        viewController.onFallbackLogin = { [weak self] in
            self?.showAuth()
        }
        window.rootViewController = viewController
    }

    private func showMain() {
        let tabCoordinator = TabBarCoordinator(window: window, container: container)
        tabCoordinator.onLogout = { [weak self, weak tabCoordinator] in
            guard let self, let tabCoordinator else { return }
            SessionManager.shared.logout()
            LocalNotificationService.shared.cancelAllScheduledNotifications()
            self.removeChild(tabCoordinator)
            self.showAuth()
        }
        addChild(tabCoordinator)
        refreshNotificationsIfNeeded()
    }
}
