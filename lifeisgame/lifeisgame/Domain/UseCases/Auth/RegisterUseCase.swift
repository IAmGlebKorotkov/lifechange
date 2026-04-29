//
//  RegisterUseCase.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.04.2026.
//

import Foundation

final class RegisterUseCase {

    enum RegisterError: LocalizedError {
        case emailAlreadyTaken
        var errorDescription: String? {
            "Пользователь с таким email уже зарегистрирован"
        }
    }

    private let repository: UserRepositoryProtocol

    init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }

    func execute(name: String, email: String, birthDate: Date?, password: String) throws -> User {
        if let _ = try repository.fetchUser(byEmail: email) {
            throw RegisterError.emailAlreadyTaken
        }
        return try repository.createUser(name: name, email: email, birthDate: birthDate, password: password)
    }
}
