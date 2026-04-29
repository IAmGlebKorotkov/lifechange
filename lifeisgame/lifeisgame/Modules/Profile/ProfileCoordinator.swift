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

    func start() {
        let viewModel = ProfileViewModel()
        let vc = ProfileViewController(viewModel: viewModel)
        viewModel.onLogoutRequested = { [weak self] in
            self?.onLogout?()
        }
        rootViewController = vc
    }
}
