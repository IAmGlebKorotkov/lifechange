//
//  ProfileViewModel.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.03.2026.
//

import Foundation
import LocalAuthentication

struct ProfileViewData {
    let name: String
    let email: String
    let passwordMask: String
    let isFaceIDEnabled: Bool
}

final class ProfileViewModel {

    private let userRepository: UserRepositoryProtocol
    private let diaryRepository: DiaryRepositoryProtocol

    var onLogoutRequested: (() -> Void)?
    var onProfileUpdated: ((ProfileViewData) -> Void)?
    var onFaceIDStateChanged: ((Bool) -> Void)?
    var onNotificationsStateChanged: ((Bool) -> Void)?
    var onError: ((String) -> Void)?

    init(userRepository: UserRepositoryProtocol, diaryRepository: DiaryRepositoryProtocol) {
        self.userRepository = userRepository
        self.diaryRepository = diaryRepository
    }

    func loadProfile() {
        guard let userID = SessionManager.shared.currentUserID else {
            onError?("Не удалось найти активную сессию")
            return
        }

        do {
            guard let user = try userRepository.fetchUser(byID: userID) else {
                onError?("Пользователь не найден")
                return
            }

            onProfileUpdated?(ProfileViewData(
                name: user.name,
                email: user.email,
                passwordMask: "••••••••",
                isFaceIDEnabled: SessionManager.shared.isFaceIDEnabled
                    && SessionManager.shared.faceIDUserID == user.id
            ))
        } catch {
            onError?(error.localizedDescription)
        }
    }

    func setFaceIDEnabled(_ isEnabled: Bool) {
        guard isEnabled else {
            SessionManager.shared.disableFaceID()
            onFaceIDStateChanged?(false)
            return
        }

        guard let userID = SessionManager.shared.currentUserID else {
            onFaceIDStateChanged?(false)
            onError?("Не удалось найти активную сессию")
            return
        }

        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error),
              context.biometryType == .faceID else {
            onFaceIDStateChanged?(false)
            onError?("Face ID недоступен на этом устройстве")
            return
        }

        context.evaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            localizedReason: "Подтвердите вход через Face ID"
        ) { [weak self] success, error in
            DispatchQueue.main.async {
                if success {
                    SessionManager.shared.enableFaceID(for: userID)
                    self?.onFaceIDStateChanged?(true)
                } else {
                    self?.onFaceIDStateChanged?(false)
                    self?.onError?(error?.localizedDescription ?? "Face ID не подтвержден")
                }
            }
        }
    }

    func setNotificationsEnabled(_ isEnabled: Bool) {
        LocalNotificationService.shared.setNotificationsEnabled(
            isEnabled,
            diaryRepository: diaryRepository
        ) { [weak self] isGranted in
            self?.onNotificationsStateChanged?(isGranted)
            if isEnabled && !isGranted {
                self?.onError?("Разрешите уведомления в настройках iOS")
            }
        }
    }
}
