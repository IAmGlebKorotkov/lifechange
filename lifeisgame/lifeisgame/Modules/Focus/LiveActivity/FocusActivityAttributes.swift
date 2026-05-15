//
//  FocusActivityAttributes.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 16.05.2026.
//

import ActivityKit
import Foundation

struct FocusActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        let endDate: Date
    }

    let taskTitle: String
    let taskTypeTitle: String
}
