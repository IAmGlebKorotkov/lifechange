//
//  CalendarEventService.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.04.2026.
//

import Foundation
import EventKit

final class CalendarEventService: CalendarServiceProtocol {

    private let store = EKEventStore()

    func fetchEvents(for date: Date, userID: UUID, completion: @escaping ([TaskItem]) -> Void) {
        requestAccess { [weak self] granted in
            guard granted, let self else {
                completion([])
                return
            }
            let tasks = self.loadEvents(for: date, userID: userID)
            completion(tasks)
        }
    }

    private func requestAccess(completion: @escaping (Bool) -> Void) {
        if #available(iOS 17.0, *) {
            store.requestFullAccessToEvents { granted, _ in
                completion(granted)
            }
        } else {
            store.requestAccess(to: .event) { granted, _ in
                completion(granted)
            }
        }
    }

    private func loadEvents(for date: Date, userID: UUID) -> [TaskItem] {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: date)
        let end = calendar.date(byAdding: .day, value: 1, to: start) ?? start

        let predicate = store.predicateForEvents(withStart: start, end: end, calendars: nil)
        return store.events(matching: predicate).map {
            CalendarEventTranslator.translate($0, userID: userID)
        }
    }
}
