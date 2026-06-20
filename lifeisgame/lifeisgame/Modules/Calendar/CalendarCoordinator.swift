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
        let viewModel = CalendarViewModel(taskService: container.makeTaskService())
        let vc = CalendarViewController(viewModel: viewModel)
        viewModel.onAddTaskTapped = { [weak self] selectedDate in
            self?.showAddTask(selectedDate: selectedDate)
        }
        viewModel.onEditTaskTapped = { [weak self, weak viewModel] task in
            self?.showEditTask(task: task, onSaved: {
                viewModel?.refresh()
            })
        }
        viewModel.onNotificationsTapped = { [weak self] in
            self?.showNotifications()
        }
        navigationController.setViewControllers([vc], animated: false)
    }

    private func showAddTask(selectedDate: Date) {
        let mainTab = navigationController.parent as? MainTabBarController
        mainTab?.setTabBarHidden(true, animated: true)
        navigationController.setNavigationBarHidden(false, animated: true)

        let coordinator = AddTaskCoordinator(
            navigationController: navigationController,
            taskService: container.makeTaskService(),
            initialDate: selectedDate
        )
        coordinator.onCompleted = { [weak self, weak coordinator, weak mainTab] in
            guard let self, let coordinator else { return }
            self.removeChild(coordinator)
            mainTab?.selectTab(index: 0)
            mainTab?.setTabBarHidden(false, animated: true)
            self.navigationController.setNavigationBarHidden(true, animated: true)
            self.navigationController.popToRootViewController(animated: true)
        }
        addChild(coordinator)
    }

    private func showEditTask(task: TaskItem, onSaved: @escaping () -> Void) {
        let mainTab = navigationController.parent as? MainTabBarController
        mainTab?.setTabBarHidden(true, animated: true)
        navigationController.setNavigationBarHidden(false, animated: true)

        let viewModel = EditTaskViewModel(
            task: task,
            taskService: container.makeTaskService()
        )
        let vc = EditTaskViewController(viewModel: viewModel)
        vc.onSaved = onSaved
        navigationController.pushViewController(vc, animated: true)
    }

    private func showNotifications() {
        let mainTab = navigationController.parent as? MainTabBarController
        mainTab?.setTabBarHidden(true, animated: true)
        navigationController.setNavigationBarHidden(false, animated: true)

        let vc = NotificationsViewController()
        navigationController.pushViewController(vc, animated: true)
    }
}
