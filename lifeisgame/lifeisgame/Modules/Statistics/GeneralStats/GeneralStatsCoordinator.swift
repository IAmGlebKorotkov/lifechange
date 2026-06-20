//
//  GeneralStatsCoordinator.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.03.2026.
//

import UIKit
import SwiftUI

final class GeneralStatsCoordinator: Coordinator {

    var childCoordinators: [Coordinator] = []
    private(set) var rootViewController: UIViewController!
    private let container: DIContainer

    init(container: DIContainer) {
        self.container = container
    }

    func start() {
        let viewModel = GeneralStatsViewModel(
            analysisService: container.makeAnalysisService()
        )
        let vc = GeneralStatisticsViewController(viewModel: viewModel)
        viewModel.onAchievementsTapped = { [weak self, weak vc] in
            guard let self else { return }
            let achievements = UIHostingController(
                rootView: AchievementsView(achievementService: self.container.makeAchievementService())
            )
            achievements.modalPresentationStyle = .fullScreen
            vc?.present(achievements, animated: true)
        }
        viewModel.onFocusTapped = { [weak self, weak vc] in
            guard let self else { return }
            let focusViewModel = FocusViewModel(
                taskService: self.container.makeTaskService(),
                achievementService: self.container.makeAchievementService()
            )
            let focus = FocusViewController(viewModel: focusViewModel)
            vc?.present(focus, animated: true)
        }
        rootViewController = vc
    }
}
