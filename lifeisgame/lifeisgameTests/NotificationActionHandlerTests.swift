//
//  NotificationActionHandlerTests.swift
//  lifeisgameTests
//

import XCTest
import UserNotifications
@testable import lifeisgame

@MainActor
final class NotificationActionHandlerTests: XCTestCase {

    func testTaskReminderCategoryContainsFocusAndCompleteActions() {
        let category = NotificationCategoryFactory.makeTaskReminderCategory()

        XCTAssertEqual(category.identifier, NotificationCategoryIdentifier.taskReminder)
        XCTAssertEqual(
            category.actions.map(\.identifier),
            [
                NotificationActionIdentifier.startFocus,
                NotificationActionIdentifier.completeTask
            ]
        )
        XCTAssertTrue(category.actions[0].options.contains(.foreground))
        XCTAssertTrue(category.actions[1].options.contains(.authenticationRequired))
    }

    func testStartFocusActionReturnsRouteForPayloadTask() {
        let taskID = UUID()
        let completer = NotificationTaskCompleterStub()
        let canceller = NotificationTaskReminderCancellerStub()
        let handler = NotificationActionHandler(
            taskCompleter: completer,
            reminderCanceller: canceller
        )

        let result = handler.handle(
            actionIdentifier: NotificationActionIdentifier.startFocus,
            userInfo: [NotificationUserInfoKey.taskID: taskID.uuidString]
        )

        XCTAssertEqual(result, .startFocus(taskID: taskID))
        XCTAssertTrue(completer.completedTaskIDs.isEmpty)
        XCTAssertTrue(canceller.cancelledTaskIDs.isEmpty)
    }

    func testDefaultTapReturnsStartFocusRoute() {
        let taskID = UUID()
        let handler = NotificationActionHandler(
            taskCompleter: NotificationTaskCompleterStub(),
            reminderCanceller: NotificationTaskReminderCancellerStub()
        )

        let result = handler.handle(
            actionIdentifier: UNNotificationDefaultActionIdentifier,
            userInfo: [NotificationUserInfoKey.taskID: taskID.uuidString]
        )

        XCTAssertEqual(result, .startFocus(taskID: taskID))
    }

    func testCompleteActionCompletesTaskAndCancelsItsReminders() {
        let taskID = UUID()
        let completer = NotificationTaskCompleterStub()
        let canceller = NotificationTaskReminderCancellerStub()
        let handler = NotificationActionHandler(
            taskCompleter: completer,
            reminderCanceller: canceller
        )

        let result = handler.handle(
            actionIdentifier: NotificationActionIdentifier.completeTask,
            userInfo: [NotificationUserInfoKey.taskID: taskID.uuidString]
        )

        XCTAssertEqual(result, .taskCompleted(taskID: taskID))
        XCTAssertEqual(completer.completedTaskIDs, [taskID])
        XCTAssertEqual(canceller.cancelledTaskIDs, [taskID])
    }

    func testActionWithoutValidTaskIDIgnoresPayload() {
        let completer = NotificationTaskCompleterStub()
        let canceller = NotificationTaskReminderCancellerStub()
        let handler = NotificationActionHandler(
            taskCompleter: completer,
            reminderCanceller: canceller
        )

        let result = handler.handle(
            actionIdentifier: NotificationActionIdentifier.completeTask,
            userInfo: [NotificationUserInfoKey.taskID: "not-a-uuid"]
        )

        XCTAssertEqual(result, .ignored)
        XCTAssertTrue(completer.completedTaskIDs.isEmpty)
        XCTAssertTrue(canceller.cancelledTaskIDs.isEmpty)
    }
}

private final class NotificationTaskCompleterStub: NotificationTaskCompleting {
    private(set) var completedTaskIDs: [UUID] = []

    func setCompleted(taskID: UUID) throws {
        completedTaskIDs.append(taskID)
    }
}

private final class NotificationTaskReminderCancellerStub: NotificationTaskReminderCancelling {
    private(set) var cancelledTaskIDs: [UUID] = []

    func cancelTaskReminders(for taskID: UUID) {
        cancelledTaskIDs.append(taskID)
    }
}
