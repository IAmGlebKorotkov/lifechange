//
//  RegistrationViewModel.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.03.2026.
//

import Foundation

final class RegistrationViewModel {

    private let registerUseCase: RegisterUseCase

    var onLoginTapped: (() -> Void)?
    var onRegisterSuccess: (() -> Void)?
    var onError: ((String) -> Void)?

    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "dd.MM.yyyy"
        return f
    }()

    init(registerUseCase: RegisterUseCase) {
        self.registerUseCase = registerUseCase
    }

    func loginTapped() {
        onLoginTapped?()
    }

    func registerTapped(name: String, email: String, birthDateText: String, password: String) {
        let birthDate = dateFormatter.date(from: birthDateText)
        do {
            let user = try registerUseCase.execute(
                name: name, email: email, birthDate: birthDate, password: password
            )
            SessionManager.shared.currentUserID = user.id
            onRegisterSuccess?()
        } catch {
            onError?(error.localizedDescription)
        }
    }
}
