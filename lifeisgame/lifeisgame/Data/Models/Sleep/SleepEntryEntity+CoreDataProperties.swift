//
//  SleepEntryEntity+CoreDataProperties.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 08.05.2026.
//

import Foundation
import CoreData

extension SleepEntryEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SleepEntryEntity> {
        NSFetchRequest<SleepEntryEntity>(entityName: "SleepEntryEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var dayDate: Date?
    @NSManaged public var bedtime: Date?
    @NSManaged public var wakeTime: Date?
    @NSManaged public var durationMinutes: Int32
    @NSManaged public var createdAt: Date?
    @NSManaged public var owner: UserEntity?
}
