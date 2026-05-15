//
//  FocusBlockingSelectionStore.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 15.05.2026.
//

import Combine
import FamilyControls
import Foundation
import ManagedSettings

@MainActor
final class FocusBlockingSelectionStore: ObservableObject {

    static let shared = FocusBlockingSelectionStore()

    @Published var selection = FamilyActivitySelection()
    @Published private(set) var authorizationError: String?

    private let managedSettingsStore = ManagedSettingsStore()

    var selectedItemsCount: Int {
        selection.applicationTokens.count + selection.categoryTokens.count + selection.webDomainTokens.count
    }

    private init() {}

    func requestAuthorization() async -> Bool {
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            authorizationError = nil
            return true
        } catch {
            let nsError = error as NSError
            authorizationError = "Не удалось получить доступ к Screen Time: \(nsError.domain) \(nsError.code)"
            return false
        }
    }

    func applyShielding() {
        managedSettingsStore.shield.applications = selection.applicationTokens.isEmpty ? nil : selection.applicationTokens
        managedSettingsStore.shield.applicationCategories = selection.categoryTokens.isEmpty
            ? nil
            : .specific(selection.categoryTokens, except: Set())
        managedSettingsStore.shield.webDomains = selection.webDomainTokens.isEmpty ? nil : selection.webDomainTokens
    }

    func clearShielding() {
        managedSettingsStore.clearAllSettings()
    }
}
