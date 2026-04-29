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
        if SessionManager.shared.isLoggedIn {
            showMain()
        } else {
            showAuth()
        }
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

    private func showMain() {
        let tabCoordinator = TabBarCoordinator(window: window, container: container)
        tabCoordinator.onLogout = { [weak self, weak tabCoordinator] in
            guard let self, let tabCoordinator else { return }
            SessionManager.shared.logout()
            self.removeChild(tabCoordinator)
            self.showAuth()
        }
        addChild(tabCoordinator)
    }
}
