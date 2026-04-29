//
//  KeychainManager.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.04.2026.
//

import Foundation
import Security
import CryptoKit

final class KeychainManager {

    static let shared = KeychainManager()
    private init() {}

    private let service = "com.lifeisgame.password"

    func savePassword(_ password: String, forUserID id: UUID) {
        let hash = hashPassword(password, salt: id.uuidString)
        guard let data = hash.data(using: .utf8) else { return }
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: id.uuidString
        ]
        SecItemDelete(query as CFDictionary)
        var attributes = query
        attributes[kSecValueData] = data
        SecItemAdd(attributes as CFDictionary, nil)
    }

    func verifyPassword(_ password: String, forUserID id: UUID) -> Bool {
        guard let stored = loadHash(forUserID: id) else { return false }
        return hashPassword(password, salt: id.uuidString) == stored
    }

    func deletePassword(forUserID id: UUID) {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: id.uuidString
        ]
        SecItemDelete(query as CFDictionary)
    }

    private func loadHash(forUserID id: UUID) -> String? {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: id.uuidString,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne
        ]
        var result: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    private func hashPassword(_ password: String, salt: String) -> String {
        let combined = Data((password + salt).utf8)
        let digest = SHA256.hash(data: combined)
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
