//
//  CalendarEventTranslator.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.04.2026.
//

import Foundation
import EventKit
import CryptoKit

enum CalendarEventTranslator {

    static func translate(_ event: EKEvent, userID: UUID) -> TaskItem {
        let deterministicID = makeUUID(from: event.calendarItemIdentifier)
        let start = event.startDate ?? Date()
        let end = event.endDate ?? start.addingTimeInterval(3600)

        return TaskItem(
            id: deterministicID,
            name: event.title ?? "Без названия",
            taskDescription: event.notes,
            startDate: start,
            deadlineDate: end,
            isCompleted: false,
            isHardTask: false,
            planningStartDate: start,
            planningDeadlineDate: end,
            importance: 5,
            difficulty: 5,
            estimatedDuration: end.timeIntervalSince(start),
            createdAt: start,
            ownerId: userID,
            parentTaskId: nil,
            subtasks: [],
            source: .calendar
        )
    }

    private static func makeUUID(from string: String) -> UUID {
        let digest = SHA256.hash(data: Data(string.utf8))
        var bytes = Array(digest.prefix(16))
        bytes[6] = (bytes[6] & 0x0F) | 0x50
        bytes[8] = (bytes[8] & 0x3F) | 0x80
        return UUID(uuid: (
            bytes[0], bytes[1], bytes[2], bytes[3],
            bytes[4], bytes[5], bytes[6], bytes[7],
            bytes[8], bytes[9], bytes[10], bytes[11],
            bytes[12], bytes[13], bytes[14], bytes[15]
        ))
    }
}
