//
//  Coordinator.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.03.2026.
//

import UIKit

protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }
    func start()
}

extension Coordinator {
    func addChild(_ coordinator: Coordinator) {
        childCoordinators.append(coordinator)
        coordinator.start()
    }

    func removeChild(_ coordinator: Coordinator) {
        childCoordinators = childCoordinators.filter { $0 !== coordinator }
    }
}
