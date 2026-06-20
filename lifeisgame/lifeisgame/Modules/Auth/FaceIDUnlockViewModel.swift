//
//  FaceIDUnlockViewModel.swift
//  lifeisgame
//
//  Created by Codex on 20.06.2026.
//

import Foundation
import LocalAuthentication

final class FaceIDUnlockViewModel {

    var onUnlocked: (() -> Void)?
    var onError: ((String) -> Void)?

    private let authService: AuthService

    init(authService: AuthService) {
        self.authService = authService
    }

    func authenticate() {
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
                self.unlock(userID: userID)
            }
        }
    }

    private func unlock(userID: UUID) {
        do {
            guard try authService.fetchUser(byID: userID) != nil else {
                SessionManager.shared.disableFaceID()
                onError?("Аккаунт для Face ID не найден")
                return
            }

            SessionManager.shared.currentUserID = userID
            onUnlocked?()
        } catch {
            onError?(error.localizedDescription)
        }
    }
}
