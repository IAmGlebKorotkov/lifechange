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

    func start() {
        rootViewController = StatisticsViewController()
    }
}
