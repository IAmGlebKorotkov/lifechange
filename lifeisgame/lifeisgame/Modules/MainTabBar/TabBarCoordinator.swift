//
//  TabBarCoordinator.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.03.2026.
//

import UIKit

final class TabBarCoordinator: Coordinator {

    var childCoordinators: [Coordinator] = []
    var onLogout: (() -> Void)?

    private let window: UIWindow
    private let container: DIContainer
    private let tabBarController = MainTabBarController()

    init(window: UIWindow, container: DIContainer) {
        self.window = window
        self.container = container
    }

    func start() {
        let vcs = [
            makeCalendarTab(),
            makeDiaryTab(),
            makeGeneralStatsTab(),
            makeStatisticsTab(),
            makeProfileTab()
        ]
        tabBarController.configure(with: vcs)

        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve) {
            self.window.rootViewController = self.tabBarController
        }
    }

    private func makeCalendarTab() -> UIViewController {
        let nav = UINavigationController()
        nav.setNavigationBarHidden(true, animated: false)
        let coordinator = CalendarCoordinator(navigationController: nav, container: container)
        addChild(coordinator)
        return nav
    }

    private func makeDiaryTab() -> UIViewController {
        let coordinator = DiaryCoordinator(container: container)
        addChild(coordinator)
        return coordinator.rootViewController
    }

    private func makeGeneralStatsTab() -> UIViewController {
        let coordinator = GeneralStatsCoordinator(container: container)
        addChild(coordinator)
        return coordinator.rootViewController
    }

    private func makeStatisticsTab() -> UIViewController {
        let coordinator = StatisticsCoordinator(container: container)
        addChild(coordinator)
        return coordinator.rootViewController
    }

    private func makeProfileTab() -> UIViewController {
        let coordinator = ProfileCoordinator(container: container)
        coordinator.onLogout = { [weak self] in self?.onLogout?() }
        addChild(coordinator)
        return coordinator.rootViewController
    }
}
