//
//  RegistrationViewModel.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.03.2026.
//

import Foundation

final class RegistrationViewModel {

    private let authService: AuthService
    private let validator: RegistrationValidator

    var onLoginTapped: (() -> Void)?
    var onRegisterSuccess: (() -> Void)?
    var onError: ((String) -> Void)?

    init(authService: AuthService, validator: RegistrationValidator = RegistrationValidator()) {
        self.authService = authService
        self.validator = validator
    }

    func loginTapped() {
        onLoginTapped?()
    }

    func validate(name: String, email: String, birthDate: String, password: String) -> RegistrationValidationResult {
        validator.validate(RegistrationValidationInput(
            name: name,
            email: email,
            birthDate: birthDate,
            password: password
        ))
    }

    func registerTapped(name: String, email: String, birthDateText: String, password: String) {
        let birthDate = DateFormatter.appDate(from: birthDateText)
        do {
            let user = try authService.register(
                name: name, email: email, birthDate: birthDate, password: password
            )
            SessionManager.shared.currentUserID = user.id
            onRegisterSuccess?()
        } catch {
            onError?(error.localizedDescription)
        }
    }
}
