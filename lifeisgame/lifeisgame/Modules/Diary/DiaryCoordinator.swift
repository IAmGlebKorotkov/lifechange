//
//  DiaryCoordinator.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.03.2026.
//

import UIKit

final class DiaryCoordinator: Coordinator {

    var childCoordinators: [Coordinator] = []
    private(set) var rootViewController: UIViewController!
    private let container: DIContainer

    init(container: DIContainer) {
        self.container = container
    }

    func start() {
        rootViewController = DiaryViewController(repository: container.makeDiaryRepository())
    }
}
