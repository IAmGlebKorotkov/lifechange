//
//  LoginValidator.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 09.04.2026.
//

import Foundation


struct LoginValidationInput {
    let email: String
    let password: String
}


enum LoginValidationError: Equatable {
    case emptyEmail
    case emptyPassword

    var message: String {
        switch self {
        case .emptyEmail:    return "Введите почту"
        case .emptyPassword: return "Введите пароль"
        }
    }
}


struct LoginValidationResult {
    let isValid: Bool
    let errors: [LoginValidationError]
}


struct LoginValidator {

    func validate(_ input: LoginValidationInput) -> LoginValidationResult {
        var errors: [LoginValidationError] = []

        if input.email.trimmingCharacters(in: .whitespaces).isEmpty {
            errors.append(.emptyEmail)
        }

        if input.password.isEmpty {
            errors.append(.emptyPassword)
        }

        return LoginValidationResult(isValid: errors.isEmpty, errors: errors)
    }
}
