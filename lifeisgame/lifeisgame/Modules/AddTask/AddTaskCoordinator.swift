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
    private let initialDate: Date

    var onCompleted: (() -> Void)?

    init(navigationController: UINavigationController, createTaskUseCase: CreateTaskUseCase, initialDate: Date = Date()) {
        self.navigationController = navigationController
        self.createTaskUseCase = createTaskUseCase
        self.initialDate = initialDate
    }

    func start() {
        let vc = AddTaskViewController()
        vc.configureInitialDate(initialDate)
        vc.onAddSubtaskTapped = { [weak self] parentName, onAdded in
            self?.showAddSubtask(parentTaskName: parentName, onAdded: onAdded)
        }
        vc.onEditSubtask = { [weak self] parentName, currentSubtask, onSaved in
            self?.showEditSubtask(parentTaskName: parentName, currentSubtask: currentSubtask, onSaved: onSaved)
        }
        vc.onGenerate = { [weak self] input in
            self?.showGeneratedPlan(input: input)
        }
        navigationController.pushViewController(vc, animated: true)
    }

    private func showAddSubtask(parentTaskName: String, onAdded: @escaping (CreateTaskUseCase.SubtaskInput) -> Void) {
        let vc = AddSubtaskViewController(parentTaskName: parentTaskName, mode: .add)
        vc.onSubtaskAdded = onAdded
        navigationController.pushViewController(vc, animated: true)
    }

    private func showEditSubtask(
        parentTaskName: String,
        currentSubtask: CreateTaskUseCase.SubtaskInput,
        onSaved: @escaping (CreateTaskUseCase.SubtaskInput) -> Void
    ) {
        let vc = AddSubtaskViewController(parentTaskName: parentTaskName, mode: .edit(currentSubtask: currentSubtask, onSaved: onSaved))
        navigationController.pushViewController(vc, animated: true)
    }

    private func showGeneratedPlan(input: CreateTaskUseCase.Input) {
        guard let userID = SessionManager.shared.currentUserID else {
            return
        }

        createTaskUseCase.execute(input: input, userID: userID) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let task):
                if input.isEvent {
                    self.presentGeneratedPlan(tasks: [task], isEvent: true)
                } else {
                    self.presentSplitPromptIfNeeded(task: task, userID: userID)
                }
            case .failure:
                break
            }
        }
    }

    private func presentSplitPromptIfNeeded(task: TaskItem, userID: UUID) {
        guard let boundary = createTaskUseCase.lateBoundary(for: task),
              let presenter = navigationController.topViewController else {
            presentGeneratedPlan(tasks: [task])
            return
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let alert = UIAlertController(
            title: "Разделить задачу?",
            message: "Часть задачи уходит после \(formatter.string(from: boundary)). Перенести остаток на утро?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Оставить как есть", style: .cancel) { [weak self] _ in
            self?.presentGeneratedPlan(tasks: [task])
        })
        alert.addAction(UIAlertAction(title: "Разделить", style: .default) { [weak self] _ in
            guard let self else { return }
            let tasks = (try? self.createTaskUseCase.splitTaskAtLateBoundary(task, userID: userID)) ?? [task]
            self.presentGeneratedPlan(tasks: tasks)
        })

        presenter.present(alert, animated: true)
    }

    private func presentGeneratedPlan(tasks: [TaskItem], isEvent: Bool = false) {
        LocalNotificationService.shared.scheduleTaskReminders(for: tasks)

        let resultVC = GeneratePlanLoadingViewController(tasks: tasks, isEvent: isEvent)
        resultVC.modalPresentationStyle = .overFullScreen
        resultVC.modalTransitionStyle = .crossDissolve
        resultVC.onCompleted = { [weak self, weak resultVC] in
            resultVC?.dismiss(animated: true) {
                self?.onCompleted?()
            }
        }
        navigationController.present(resultVC, animated: true)
    }
}
