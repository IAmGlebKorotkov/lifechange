//
//  UserRepository.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.04.2026.
//

import Foundation
import CoreData

final class UserRepository: UserRepositoryProtocol {

    private let persistence: PersistenceController
    private let keychain: KeychainManager

    init(persistence: PersistenceController = .shared,
         keychain: KeychainManager = .shared) {
        self.persistence = persistence
        self.keychain = keychain
    }

    func createUser(name: String, email: String, birthDate: Date?, password: String) throws -> User {
        let ctx = persistence.context
        let entity = UserEntity(context: ctx)
        entity.id = UUID()
        entity.name = name
        entity.email = email.lowercased().trimmingCharacters(in: .whitespaces)
        entity.birthDate = birthDate
        entity.createdAt = Date()
        persistence.save()
        guard let id = entity.id else {
            throw RepositoryError.mappingFailed
        }
        keychain.savePassword(password, forUserID: id)
        guard let user = UserMapper.toDomain(entity) else {
            throw RepositoryError.mappingFailed
        }
        return user
    }

    func verifyCredentials(email: String, password: String) throws -> User {
        guard let entity = try fetchEntity(byEmail: email) else {
            throw RepositoryError.invalidCredentials
        }
        guard let id = entity.id,
              keychain.verifyPassword(password, forUserID: id) else {
            throw RepositoryError.invalidCredentials
        }
        guard let user = UserMapper.toDomain(entity) else {
            throw RepositoryError.mappingFailed
        }
        return user
    }

    func fetchUser(byEmail email: String) throws -> User? {
        try fetchEntity(byEmail: email).flatMap { UserMapper.toDomain($0) }
    }

    func fetchUser(byID id: UUID) throws -> User? {
        let request = UserEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        return try persistence.context.fetch(request).first.flatMap { UserMapper.toDomain($0) }
    }

    private func fetchEntity(byEmail email: String) throws -> UserEntity? {
        let normalized = email.lowercased().trimmingCharacters(in: .whitespaces)
        let request = UserEntity.fetchRequest()
        request.predicate = NSPredicate(format: "email ==[c] %@", normalized)
        request.fetchLimit = 1
        return try persistence.context.fetch(request).first
    }
}
