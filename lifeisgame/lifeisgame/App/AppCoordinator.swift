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
    private var pendingURL: URL?

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
        LocalNotificationService.shared.refreshDiaryReminders(diaryService: container.makeDiaryService())
    }

    func handle(url: URL) {
        guard url.scheme == "lifeisgame",
              url.host == "focus",
              url.path == "/complete",
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let taskIDValue = components.queryItems?.first(where: { $0.name == "taskID" })?.value,
              let taskID = UUID(uuidString: taskIDValue) else { return }

        guard SessionManager.shared.canRestoreSessionWithoutAuth else {
            pendingURL = url
            return
        }

        completeLiveActivityTask(taskID)
    }

    private func completeLiveActivityTask(_ taskID: UUID) {
        try? container.makeTaskService().setCompleted(taskID: taskID)
        FocusLiveActivityManager.shared.end()
        NotificationCenter.default.post(
            name: .focusLiveActivityTaskCompleted,
            object: nil,
            userInfo: [FocusLiveActivityNotificationKey.taskID: taskID]
        )
    }

    private func processPendingURLIfNeeded() {
        guard let pendingURL else { return }
        self.pendingURL = nil
        handle(url: pendingURL)
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
        let viewModel = FaceIDUnlockViewModel(authService: container.makeAuthService())
        let viewController = FaceIDUnlockViewController(viewModel: viewModel)
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
        processPendingURLIfNeeded()
    }
}
