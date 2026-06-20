//
//  ProfileCoordinator.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.03.2026.
//

import UIKit

final class ProfileCoordinator: Coordinator {

    var childCoordinators: [Coordinator] = []
    var onLogout: (() -> Void)?
    private(set) var rootViewController: UIViewController!
    private let container: DIContainer

    init(container: DIContainer) {
        self.container = container
    }

    func start() {
        let viewModel = ProfileViewModel(
            authService: container.makeAuthService(),
            diaryService: container.makeDiaryService()
        )
        let vc = ProfileViewController(viewModel: viewModel)
        viewModel.onLogoutRequested = { [weak self] in
            self?.onLogout?()
        }
        rootViewController = vc
    }
}
