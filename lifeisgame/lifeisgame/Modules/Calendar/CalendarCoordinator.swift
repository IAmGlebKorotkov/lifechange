//
//  CalendarCoordinator.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.03.2026.
//

import UIKit

final class CalendarCoordinator: Coordinator {

    var childCoordinators: [Coordinator] = []
    private let navigationController: UINavigationController
    private let container: DIContainer

    init(navigationController: UINavigationController, container: DIContainer) {
        self.navigationController = navigationController
        self.container = container
    }

    func start() {
        let viewModel = CalendarViewModel(
            fetchTasksUseCase: container.makeFetchTasksUseCase(),
            toggleUseCase: container.makeToggleTaskCompletionUseCase()
        )
        let vc = CalendarViewController(viewModel: viewModel)
        viewModel.onAddTaskTapped = { [weak self] in
            self?.showAddTask()
        }
        navigationController.setViewControllers([vc], animated: false)
    }

    private func showAddTask() {
        let mainTab = navigationController.parent as? MainTabBarController
        mainTab?.setTabBarHidden(true, animated: true)
        navigationController.setNavigationBarHidden(false, animated: true)

        let coordinator = AddTaskCoordinator(
            navigationController: navigationController,
            createTaskUseCase: container.makeCreateTaskUseCase()
        )
        coordinator.onCompleted = { [weak self, weak coordinator] in
            guard let self, let coordinator else { return }
            self.removeChild(coordinator)
            let mainTab = self.navigationController.parent as? MainTabBarController
            mainTab?.setTabBarHidden(false, animated: true)
            self.navigationController.setNavigationBarHidden(true, animated: true)
            self.navigationController.popToRootViewController(animated: true)
        }
        addChild(coordinator)
    }
}
