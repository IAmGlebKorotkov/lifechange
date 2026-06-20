//
//  FocusActivityAttributes.swift
//  FocusLiveActivityExtension
//
//  Created by Gleb Korotkov on 09.05.2026.
//

import ActivityKit
import Foundation

struct FocusActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        let endDate: Date
    }

    let taskID: UUID
    let taskTitle: String
    let taskTypeTitle: String
}
