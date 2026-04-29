//
//  LoginViewModel.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.03.2026.
//

import Foundation

final class LoginViewModel {

    private let loginUseCase: LoginUseCase

    var onRegisterTapped: (() -> Void)?
    var onLoginSuccess: (() -> Void)?
    var onError: ((String) -> Void)?

    init(loginUseCase: LoginUseCase) {
        self.loginUseCase = loginUseCase
    }

    func registerTapped() {
        onRegisterTapped?()
    }

    func loginTapped(email: String, password: String) {
        do {
            let user = try loginUseCase.execute(email: email, password: password)
            SessionManager.shared.currentUserID = user.id
            onLoginSuccess?()
        } catch {
            onError?(error.localizedDescription)
        }
    }
}
