//
//  GeneralStatsCoordinator.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.03.2026.
//

import UIKit

final class GeneralStatsCoordinator: Coordinator {

    var childCoordinators: [Coordinator] = []
    private(set) var rootViewController: UIViewController!
    private let container: DIContainer

    init(container: DIContainer) {
        self.container = container
    }

    func start() {
        let viewModel = GeneralStatsViewModel()
        let vc = GeneralStatisticsViewController(viewModel: viewModel)
        viewModel.onAchievementsTapped = { [weak vc] in
            let achievements = AchievementsViewController()
            achievements.modalPresentationStyle = .fullScreen
            vc?.present(achievements, animated: true)
        }
        viewModel.onFocusTapped = { [weak self, weak vc] in
            guard let self else { return }
            let focusViewModel = FocusViewModel(
                fetchTasksUseCase: self.container.makeFetchTasksUseCase(),
                toggleTaskCompletionUseCase: self.container.makeToggleTaskCompletionUseCase()
            )
            let focus = FocusViewController(viewModel: focusViewModel)
            vc?.present(focus, animated: true)
        }
        rootViewController = vc
    }
}
