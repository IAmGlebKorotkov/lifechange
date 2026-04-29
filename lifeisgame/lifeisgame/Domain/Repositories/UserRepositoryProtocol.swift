//
//  UserRepositoryProtocol.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.04.2026.
//

import Foundation

protocol UserRepositoryProtocol {
    func createUser(name: String, email: String, birthDate: Date?, password: String) throws -> User
    func verifyCredentials(email: String, password: String) throws -> User
    func fetchUser(byEmail email: String) throws -> User?
    func fetchUser(byID id: UUID) throws -> User?
}
