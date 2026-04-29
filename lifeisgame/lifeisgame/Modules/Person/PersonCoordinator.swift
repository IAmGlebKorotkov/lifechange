//
//  PersonCoordinator.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.03.2026.
//

import UIKit

final class PersonCoordinator: Coordinator {

    var childCoordinators: [Coordinator] = []
    private(set) var rootViewController: UIViewController!

    func start() {
        rootViewController = PersonViewController()
    }
}
