//
//  AuthService.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 19.06.2026.
//

import Foundation

final class AuthService {

    enum AuthError: LocalizedError {
        case invalidCredentials
        case emailAlreadyTaken

        var errorDescription: String? {
            switch self {
            case .invalidCredentials:
                return "Неверный логин или пароль"
            case .emailAlreadyTaken:
                return "Пользователь с таким email уже зарегистрирован"
            }
        }
    }

    private let userRepository: UserRepositoryProtocol

    init(userRepository: UserRepositoryProtocol = UserRepository()) {
        self.userRepository = userRepository
    }

    func login(email: String, password: String) throws -> User {
        do {
            return try userRepository.verifyCredentials(email: email, password: password)
        } catch {
            throw AuthError.invalidCredentials
        }
    }

    func register(name: String, email: String, birthDate: Date?, password: String) throws -> User {
        if try userRepository.fetchUser(byEmail: email) != nil {
            throw AuthError.emailAlreadyTaken
        }

        return try userRepository.createUser(
            name: name,
            email: email,
            birthDate: birthDate,
            password: password
        )
    }

    func fetchUser(byID id: UUID) throws -> User? {
        try userRepository.fetchUser(byID: id)
    }

    func fetchUser(byEmail email: String) throws -> User? {
        try userRepository.fetchUser(byEmail: email)
    }
}
