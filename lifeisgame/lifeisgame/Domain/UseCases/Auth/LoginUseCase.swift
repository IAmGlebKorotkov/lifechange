//
//  LoginUseCase.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.04.2026.
//

import Foundation

final class LoginUseCase {

    enum LoginError: LocalizedError {
        case invalidCredentials
        var errorDescription: String? {
            "Неверный логин или пароль"
        }
    }

    private let repository: UserRepositoryProtocol

    init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }

    func execute(email: String, password: String) throws -> User {
        do {
            return try repository.verifyCredentials(email: email, password: password)
        } catch {
            throw LoginError.invalidCredentials
        }
    }
}
