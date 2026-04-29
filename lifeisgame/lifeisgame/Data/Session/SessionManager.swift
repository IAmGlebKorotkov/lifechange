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

    var currentUserID: UUID? {
        get {
            guard let str = UserDefaults.standard.string(forKey: userIDKey) else { return nil }
            return UUID(uuidString: str)
        }
        set {
            UserDefaults.standard.set(newValue?.uuidString, forKey: userIDKey)
        }
    }

    var isLoggedIn: Bool { currentUserID != nil }

    func logout() {
        currentUserID = nil
    }
}
