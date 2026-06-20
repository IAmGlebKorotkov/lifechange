//
//  FocusSessionEntity+CoreDataProperties.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 12.05.2026.
//

import Foundation
import CoreData

extension FocusSessionEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FocusSessionEntity> {
        NSFetchRequest<FocusSessionEntity>(entityName: "FocusSessionEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var startedAt: Date?
    @NSManaged public var endedAt: Date?
    @NSManaged public var durationSeconds: Double
    @NSManaged public var taskID: UUID?
    @NSManaged public var createdAt: Date?
    @NSManaged public var owner: UserEntity?
}
