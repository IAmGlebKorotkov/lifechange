//
//  User.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.04.2026.
//

import Foundation

struct User: Equatable {
    let id: UUID
    var name: String
    var email: String
    var birthDate: Date?
    let createdAt: Date
}
