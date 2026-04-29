//
//  CreateTaskUseCase.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.04.2026.
//

import Foundation

final class CreateTaskUseCase {

    struct Input {
        let name: String
        let description: String?
        let startDate: Date
        let deadlineDate: Date
        let isHardTask: Bool
        let subtaskNames: [String]
    }

    private let repository: TaskRepositoryProtocol

    init(repository: TaskRepositoryProtocol) {
        self.repository = repository
    }

    func execute(input: Input, userID: UUID) throws {
        let task = try repository.createTask(
            name: input.name,
            description: input.description,
            startDate: input.startDate,
            deadlineDate: input.deadlineDate,
            isHardTask: input.isHardTask,
            ownerId: userID,
            parentTaskId: nil
        )
        for name in input.subtaskNames {
            _ = try repository.createTask(
                name: name,
                description: nil,
                startDate: input.startDate,
                deadlineDate: input.deadlineDate,
                isHardTask: false,
                ownerId: userID,
                parentTaskId: task.id
            )
        }
    }
}
