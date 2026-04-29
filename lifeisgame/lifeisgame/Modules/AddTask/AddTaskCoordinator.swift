//
//  AddTaskCoordinator.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.03.2026.
//

import UIKit

final class AddTaskCoordinator: Coordinator {

    var childCoordinators: [Coordinator] = []
    private let navigationController: UINavigationController
    private let createTaskUseCase: CreateTaskUseCase
    private var pendingInput: CreateTaskUseCase.Input?

    var onCompleted: (() -> Void)?

    init(navigationController: UINavigationController, createTaskUseCase: CreateTaskUseCase) {
        self.navigationController = navigationController
        self.createTaskUseCase = createTaskUseCase
    }

    func start() {
        let vc = AddTaskViewController()
        vc.onAddSubtaskTapped = { [weak self] parentName, onAdded in
            self?.showAddSubtask(parentTaskName: parentName, onAdded: onAdded)
        }
        vc.onEditSubtask = { [weak self] parentName, currentName, onSaved in
            self?.showEditSubtask(parentTaskName: parentName, currentName: currentName, onSaved: onSaved)
        }
        vc.onGenerate = { [weak self] input in
            self?.pendingInput = input
            self?.showLoadingAndComplete()
        }
        navigationController.pushViewController(vc, animated: true)
    }

    private func showAddSubtask(parentTaskName: String, onAdded: @escaping (String) -> Void) {
        let vc = AddSubtaskViewController(parentTaskName: parentTaskName, mode: .add)
        vc.onSubtaskAdded = onAdded
        navigationController.pushViewController(vc, animated: true)
    }

    private func showEditSubtask(parentTaskName: String, currentName: String, onSaved: @escaping (String) -> Void) {
        let vc = AddSubtaskViewController(parentTaskName: parentTaskName, mode: .edit(currentName: currentName, onSaved: onSaved))
        navigationController.pushViewController(vc, animated: true)
    }

    private func showLoadingAndComplete() {
        let loadingVC = GeneratePlanLoadingViewController()
        loadingVC.modalPresentationStyle = .overFullScreen
        loadingVC.modalTransitionStyle = .crossDissolve
        loadingVC.onCompleted = { [weak self, weak loadingVC] in
            if let input = self?.pendingInput,
               let userID = SessionManager.shared.currentUserID {
                try? self?.createTaskUseCase.execute(input: input, userID: userID)
            }
            self?.pendingInput = nil
            loadingVC?.dismiss(animated: true) {
                self?.onCompleted?()
            }
        }
        navigationController.present(loadingVC, animated: true)
    }
}
