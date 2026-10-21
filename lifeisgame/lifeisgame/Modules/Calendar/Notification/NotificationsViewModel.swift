//
//  NotificationsViewModel.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 20.06.2026.
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
                let deliveredItems = notifications
                    .map(self.makeItem)
                    .sorted { ($0.date ?? .distantPast) > ($1.date ?? .distantPast) }

                #if DEBUG
                self.onNotificationsLoaded?(
                    deliveredItems.isEmpty ? self.makeMockItems() : deliveredItems
                )
                #else
                self.onNotificationsLoaded?(deliveredItems)
                #endif
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

    #if DEBUG
    private func makeMockItems(referenceDate: Date = Date()) -> [NotificationViewData] {
        [
            NotificationViewData(
                id: "mock-focus",
                title: "Время сфокусироваться",
                body: "Самое время уделить 25 минут задаче «Подготовить презентацию».",
                date: referenceDate.addingTimeInterval(-9 * 60)
            ),
            NotificationViewData(
                id: "mock-task",
                title: "Задача на сегодня",
                body: "Не забудь завершить задачу «Тренировка» до конца дня.",
                date: referenceDate.addingTimeInterval(-75 * 60)
            ),
            NotificationViewData(
                id: "mock-diary",
                title: "Как прошёл твой день?",
                body: "Отметь настроение и сохрани важные мысли в дневнике эмоций.",
                date: referenceDate.addingTimeInterval(-4 * 60 * 60)
            ),
            NotificationViewData(
                id: "mock-achievement",
                title: "Новое достижение!",
                body: "Ты выполнил все задачи за день. Отличная работа!",
                date: referenceDate.addingTimeInterval(-25 * 60 * 60)
            ),
            NotificationViewData(
                id: "mock-summary",
                title: "Время подвести итоги",
                body: "Посмотри статистику недели и оцени свой прогресс.",
                date: referenceDate.addingTimeInterval(-49 * 60 * 60)
            )
        ]
    }
    #endif
}
