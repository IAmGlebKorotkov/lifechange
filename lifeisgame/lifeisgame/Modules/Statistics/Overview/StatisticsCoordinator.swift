//
//  StatisticsCoordinator.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.03.2026.
//

import UIKit

final class StatisticsCoordinator: Coordinator {

    var childCoordinators: [Coordinator] = []
    private(set) var rootViewController: UIViewController!
    private let container: DIContainer

    init(container: DIContainer) {
        self.container = container
    }

    func start() {
        let viewModel = StatisticsViewModel(
            diaryService: container.makeDiaryService(),
            taskService: container.makeTaskService()
        )
        rootViewController = StatisticsViewController(viewModel: viewModel)
    }
}
