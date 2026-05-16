//
//  DeleteTaskUseCase.swift
//  lifeisgame
//
//  Created by Codex on 16.05.2026.
//

import Foundation

final class DeleteTaskUseCase {

    private let repository: TaskRepositoryProtocol

    init(repository: TaskRepositoryProtocol) {
        self.repository = repository
    }

    func execute(taskID: UUID) throws {
        try repository.deleteTask(id: taskID)
    }
}
