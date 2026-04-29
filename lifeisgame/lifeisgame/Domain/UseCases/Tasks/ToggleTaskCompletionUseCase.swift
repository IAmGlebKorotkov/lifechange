//
//  ToggleTaskCompletionUseCase.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.04.2026.
//

import Foundation

final class ToggleTaskCompletionUseCase {

    private let repository: TaskRepositoryProtocol

    init(repository: TaskRepositoryProtocol) {
        self.repository = repository
    }

    func execute(taskID: UUID) throws {
        try repository.toggleCompletion(taskID: taskID)
    }
}
