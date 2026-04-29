//
//  CalendarServiceProtocol.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.04.2026.
//

import Foundation

protocol CalendarServiceProtocol {
    func fetchEvents(for date: Date, userID: UUID, completion: @escaping ([TaskItem]) -> Void)
}
