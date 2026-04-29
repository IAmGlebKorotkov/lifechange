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

    func start() {
        let viewModel = GeneralStatsViewModel()
        let vc = GeneralStatisticsViewController(viewModel: viewModel)
        viewModel.onAchievementsTapped = { [weak vc] in
            let achievements = AchievementsViewController()
            achievements.modalPresentationStyle = .fullScreen
            vc?.present(achievements, animated: true)
        }
        rootViewController = vc
    }
}
