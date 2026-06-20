//
//  NotificationsViewModel.swift
//  lifeisgame
//
//  Created by Codex on 20.06.2026.
//

import Foundation
import UserNotifications

struct NotificationViewData {
    let id: String
    let title: String
    let body: String
    let date: Date?
}

final class NotificationsViewModel {

    var onNotificationsLoaded: (([NotificationViewData]) -> Void)?

    private let notificationService: LocalNotificationService
    private let center: UNUserNotificationCenter

    init(
        notificationService: LocalNotificationService = .shared,
        center: UNUserNotificationCenter = .current()
    ) {
        self.notificationService = notificationService
        self.center = center
    }

    var areNotificationsEnabled: Bool {
        notificationService.isEnabled
    }

    func loadNotifications() {
        center.getDeliveredNotifications { [weak self] notifications in
            DispatchQueue.main.async {
                guard let self else { return }
                self.onNotificationsLoaded?(
                    notifications
                        .map(self.makeItem)
                        .sorted { ($0.date ?? .distantPast) > ($1.date ?? .distantPast) }
                )
            }
        }
    }

    private func makeItem(from notification: UNNotification) -> NotificationViewData {
        NotificationViewData(
            id: notification.request.identifier,
            title: titleText(from: notification.request.content.title),
            body: bodyText(from: notification.request.content.body),
            date: notification.date
        )
    }

    private func titleText(from value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Уведомление" : value
    }

    private func bodyText(from value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Без описания" : value
    }
}
