//
//  LoginViewModel.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.03.2026.
//

import Foundation
import LocalAuthentication

final class LoginViewModel {

    private let authService: AuthService
    private let validator: LoginValidator

    var onRegisterTapped: (() -> Void)?
    var onLoginSuccess: (() -> Void)?
    var onError: ((String) -> Void)?
    var onFaceIDAvailabilityChanged: ((Bool) -> Void)?

    init(authService: AuthService, validator: LoginValidator = LoginValidator()) {
        self.authService = authService
        self.validator = validator
    }

    func registerTapped() {
        onRegisterTapped?()
    }

    func updateFaceIDAvailability() {
        let context = LAContext()
        var error: NSError?
        let canUseBiometrics = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        onFaceIDAvailabilityChanged?(
            SessionManager.shared.isFaceIDEnabled
            && SessionManager.shared.faceIDUserID != nil
            && canUseBiometrics
            && context.biometryType == .faceID
        )
    }

    func validate(email: String, password: String) -> LoginValidationResult {
        validator.validate(LoginValidationInput(email: email, password: password))
    }

    func loginTapped(email: String, password: String) {
        do {
            let user = try authService.login(email: email, password: password)
            SessionManager.shared.currentUserID = user.id
            onLoginSuccess?()
        } catch {
            onError?(error.localizedDescription)
        }
    }

    func faceIDLoginTapped() {
        guard SessionManager.shared.isFaceIDEnabled,
              let userID = SessionManager.shared.faceIDUserID else {
            onError?("Вход через Face ID не включен")
            return
        }

        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error),
              context.biometryType == .faceID else {
            onError?("Face ID недоступен на этом устройстве")
            updateFaceIDAvailability()
            return
        }

        context.evaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            localizedReason: "Войдите в аккаунт через Face ID"
        ) { [weak self] success, error in
            DispatchQueue.main.async {
                guard let self else { return }
                guard success else {
                    self.onError?(error?.localizedDescription ?? "Face ID не подтвержден")
                    return
                }

                do {
                    guard try self.authService.fetchUser(byID: userID) != nil else {
                        SessionManager.shared.disableFaceID()
                        self.updateFaceIDAvailability()
                        self.onError?("Аккаунт для Face ID не найден")
                        return
                    }

                    SessionManager.shared.currentUserID = userID
                    self.onLoginSuccess?()
                } catch {
                    self.onError?(error.localizedDescription)
                }
            }
        }
    }
}
