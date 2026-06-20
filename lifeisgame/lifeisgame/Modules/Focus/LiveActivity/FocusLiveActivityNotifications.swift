//
//  FocusLiveActivityNotifications.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 15.05.2026.
//

import Foundation

extension Notification.Name {
    static let focusLiveActivityTaskCompleted = Notification.Name("focusLiveActivityTaskCompleted")
}

enum FocusLiveActivityNotificationKey {
    static let taskID = "taskID"
}
