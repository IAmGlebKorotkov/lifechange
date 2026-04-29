//
//  RegistrationValidationUseCase.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 09.04.2026.
//

import Foundation


struct RegistrationValidationInput {
    let name: String
    let email: String
    let birthDate: String
    let password: String
}


enum RegistrationValidationError: Equatable {
    case emptyName
    case emptyEmail
    case emptyBirthDate
    case emptyPassword
    case passwordTooShort

    var message: String {
        switch self {
        case .emptyName:       return "Введите имя"
        case .emptyEmail:      return "Введите почту"
        case .emptyBirthDate:  return "Укажите дату рождения"
        case .emptyPassword:   return "Введите пароль"
        case .passwordTooShort: return "Пароль — минимум 6 символов"
        }
    }
}


struct RegistrationValidationResult {
    let isValid: Bool
    let errors: [RegistrationValidationError]
}


struct RegistrationValidationUseCase {

    func validate(_ input: RegistrationValidationInput) -> RegistrationValidationResult {
        var errors: [RegistrationValidationError] = []

        if input.name.trimmingCharacters(in: .whitespaces).isEmpty {
            errors.append(.emptyName)
        }

        if input.email.trimmingCharacters(in: .whitespaces).isEmpty {
            errors.append(.emptyEmail)
        }

        if input.birthDate.trimmingCharacters(in: .whitespaces).isEmpty {
            errors.append(.emptyBirthDate)
        }

        if input.password.isEmpty {
            errors.append(.emptyPassword)
        } else if input.password.count < 6 {
            errors.append(.passwordTooShort)
        }

        return RegistrationValidationResult(isValid: errors.isEmpty, errors: errors)
    }
}
