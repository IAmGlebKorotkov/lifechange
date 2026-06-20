//
//  FocusLiveActivityManager.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 09.05.2026.
//

import ActivityKit
import Foundation

@MainActor
final class FocusLiveActivityManager {

    static let shared = FocusLiveActivityManager()

    private var currentActivity: Activity<FocusActivityAttributes>?
    private var currentEndDate: Date?

    private init() {}

    func start(taskID: UUID, taskTitle: String, taskTypeTitle: String, endDate: Date) {
        Task { @MainActor in
            await endExistingActivities()

            guard ActivityAuthorizationInfo().areActivitiesEnabled else {
                return
            }

            let attributes = FocusActivityAttributes(
                taskID: taskID,
                taskTitle: taskTitle,
                taskTypeTitle: taskTypeTitle
            )
            let state = FocusActivityAttributes.ContentState(endDate: endDate)
            let content = ActivityContent(state: state, staleDate: endDate)

            do {
                currentActivity = try Activity.request(
                    attributes: attributes,
                    content: content,
                    pushType: nil
                )
                currentEndDate = endDate
            } catch {
                currentActivity = nil
                currentEndDate = nil
            }
        }
    }

    func end() {
        Task { @MainActor in
            await endExistingActivities()
        }
    }

    private func endExistingActivities() async {
        let endDate = currentEndDate ?? Date()
        let finalContent = ActivityContent(
            state: FocusActivityAttributes.ContentState(endDate: endDate),
            staleDate: Date()
        )

        let currentActivityID = currentActivity?.id

        if let currentActivity {
            await currentActivity.end(finalContent, dismissalPolicy: .immediate)
        }

        for activity in Activity<FocusActivityAttributes>.activities {
            if let currentActivityID, activity.id == currentActivityID {
                continue
            }
            await activity.end(finalContent, dismissalPolicy: .immediate)
        }

        currentActivity = nil
        currentEndDate = nil
    }
}
