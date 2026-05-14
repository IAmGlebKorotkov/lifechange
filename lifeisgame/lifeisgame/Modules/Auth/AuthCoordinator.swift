//
//  AuthCoordinator.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.03.2026.
//

import UIKit

final class AuthCoordinator: Coordinator {

    var childCoordinators: [Coordinator] = []
    private let navigationController: UINavigationController
    private let container: DIContainer

    var onAuthCompleted: (() -> Void)?

    init(navigationController: UINavigationController, container: DIContainer) {
        self.navigationController = navigationController
        self.container = container
        navigationController.setNavigationBarHidden(true, animated: false)
    }

    func start() {
        showLogin()
    }

    func showLogin() {
        let viewModel = LoginViewModel(
            loginUseCase: container.makeLoginUseCase(),
            userRepository: container.makeUserRepository()
        )
        let viewController = LoginViewController(viewModel: viewModel)
        viewModel.onRegisterTapped = { [weak self] in
            self?.showRegistration()
        }
        viewModel.onLoginSuccess = { [weak self] in
            self?.onAuthCompleted?()
        }
        navigationController.setViewControllers([viewController], animated: true)
    }

    func showRegistration() {
        let viewModel = RegistrationViewModel(registerUseCase: container.makeRegisterUseCase())
        let viewController = RegistrationViewController(viewModel: viewModel)
        viewModel.onLoginTapped = { [weak self] in
            self?.showLogin()
        }
        viewModel.onRegisterSuccess = { [weak self] in
            self?.onAuthCompleted?()
        }
        navigationController.setViewControllers([viewController], animated: true)
    }
}
