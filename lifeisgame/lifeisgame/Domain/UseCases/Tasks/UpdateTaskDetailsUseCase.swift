//
//  UpdateTaskDetailsUseCase.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 16.05.2026.
//

import Foundation

final class UpdateTaskDetailsUseCase {

    struct Input {
        let taskID: UUID
        let name: String
        let description: String?
        let importance: Int
        let difficulty: Int
    }

    private let repository: TaskRepositoryProtocol

    init(repository: TaskRepositoryProtocol) {
        self.repository = repository
    }

    func execute(input: Input) throws -> TaskItem {
        try repository.updateTaskDetails(
            taskID: input.taskID,
            name: input.name,
            description: input.description,
            importance: input.importance,
            difficulty: input.difficulty
        )
    }
}
