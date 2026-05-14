//
//  SessionManager.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.04.2026.
//

import Foundation

final class SessionManager {

    static let shared = SessionManager()
    private init() {}

    private let userIDKey = "currentUserID"
    private let faceIDEnabledKey = "faceIDEnabled"
    private let faceIDUserIDKey = "faceIDUserID"
    private var unlockedUserID: UUID?

    var currentUserID: UUID? {
        get {
            guard let str = UserDefaults.standard.string(forKey: userIDKey) else { return nil }
            return UUID(uuidString: str)
        }
        set {
            if let newValue {
                UserDefaults.standard.set(newValue.uuidString, forKey: userIDKey)
                unlockedUserID = newValue
            } else {
                UserDefaults.standard.removeObject(forKey: userIDKey)
                unlockedUserID = nil
            }
        }
    }

    var isLoggedIn: Bool { currentUserID != nil }

    var canRestoreSessionWithoutAuth: Bool {
        guard let currentUserID else { return false }
        guard isFaceIDEnabled, faceIDUserID == currentUserID else { return true }
        return unlockedUserID == currentUserID
    }

    var canAttemptFaceIDUnlock: Bool {
        isFaceIDEnabled && faceIDUserID != nil
    }

    var isFaceIDEnabled: Bool {
        UserDefaults.standard.bool(forKey: faceIDEnabledKey)
    }

    var faceIDUserID: UUID? {
        guard let str = UserDefaults.standard.string(forKey: faceIDUserIDKey) else { return nil }
        return UUID(uuidString: str)
    }

    func enableFaceID(for userID: UUID) {
        UserDefaults.standard.set(true, forKey: faceIDEnabledKey)
        UserDefaults.standard.set(userID.uuidString, forKey: faceIDUserIDKey)
    }

    func disableFaceID() {
        UserDefaults.standard.set(false, forKey: faceIDEnabledKey)
        UserDefaults.standard.removeObject(forKey: faceIDUserIDKey)
    }

    func logout() {
        currentUserID = nil
    }
}
