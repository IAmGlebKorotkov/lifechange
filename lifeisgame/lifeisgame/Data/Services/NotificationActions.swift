//
//  NotificationActions.swift
//  lifeisgame
//

import Foundation
import UserNotifications

enum NotificationCategoryIdentifier {
    static let taskReminder = "TASK_REMINDER"
}

enum NotificationActionIdentifier {
    static let startFocus = "START_FOCUS"
    static let completeTask = "COMPLETE_TASK"
}

enum NotificationUserInfoKey {
    static let taskID = "taskID"
    static let type = "type"
}

enum NotificationActionResult: Equatable {
    case startFocus(taskID: UUID)
    case taskCompleted(taskID: UUID)
    case ignored
}

protocol NotificationTaskCompleting {
    func setCompleted(taskID: UUID) throws
}

extension TaskService: NotificationTaskCompleting {}

protocol NotificationTaskReminderCancelling {
    func cancelTaskReminders(for taskID: UUID)
}

extension LocalNotificationService: NotificationTaskReminderCancelling {}

final class NotificationActionHandler {

    private let taskCompleter: NotificationTaskCompleting
    private let reminderCanceller: NotificationTaskReminderCancelling

    init(
        taskCompleter: NotificationTaskCompleting,
        reminderCanceller: NotificationTaskReminderCancelling
    ) {
        self.taskCompleter = taskCompleter
        self.reminderCanceller = reminderCanceller
    }

    func handle(
        actionIdentifier: String,
        userInfo: [AnyHashable: Any]
    ) -> NotificationActionResult {
        guard let taskIDValue = userInfo[NotificationUserInfoKey.taskID] as? String,
              let taskID = UUID(uuidString: taskIDValue) else {
            return .ignored
        }

        switch actionIdentifier {
        case NotificationActionIdentifier.startFocus,
             UNNotificationDefaultActionIdentifier:
            return .startFocus(taskID: taskID)

        case NotificationActionIdentifier.completeTask:
            do {
                try taskCompleter.setCompleted(taskID: taskID)
                reminderCanceller.cancelTaskReminders(for: taskID)
                return .taskCompleted(taskID: taskID)
            } catch {
                return .ignored
            }

        default:
            return .ignored
        }
    }
}

enum NotificationCategoryFactory {

    static func makeTaskReminderCategory() -> UNNotificationCategory {
        let startFocusAction = UNNotificationAction(
            identifier: NotificationActionIdentifier.startFocus,
            title: "Начать фокус",
            options: [.foreground]
        )
        let completeTaskAction = UNNotificationAction(
            identifier: NotificationActionIdentifier.completeTask,
            title: "Выполнено",
            options: [.authenticationRequired]
        )

        return UNNotificationCategory(
            identifier: NotificationCategoryIdentifier.taskReminder,
            actions: [startFocusAction, completeTaskAction],
            intentIdentifiers: [],
            options: []
        )
    }
}

enum NotificationRoute: Equatable {
    case startFocus(taskID: UUID)
}

final class NotificationRouteStore {

    static let shared = NotificationRouteStore()

    private var pendingRoute: NotificationRoute?
    private var handler: ((NotificationRoute) -> Void)?

    private init() {}

    func setHandler(_ handler: ((NotificationRoute) -> Void)?) {
        self.handler = handler

        guard let handler, let pendingRoute else { return }
        self.pendingRoute = nil
        handler(pendingRoute)
    }

    func enqueue(_ route: NotificationRoute) {
        guard let handler else {
            pendingRoute = route
            return
        }
        handler(route)
    }
}
