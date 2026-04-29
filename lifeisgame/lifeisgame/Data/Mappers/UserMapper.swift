//
//  UserMapper.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.04.2026.
//

import Foundation

enum UserMapper {
    static func toDomain(_ entity: UserEntity) -> User? {
        guard let id = entity.id,
              let name = entity.name,
              let email = entity.email,
              let createdAt = entity.createdAt else { return nil }
        return User(id: id, name: name, email: email, birthDate: entity.birthDate, createdAt: createdAt)
    }
}
