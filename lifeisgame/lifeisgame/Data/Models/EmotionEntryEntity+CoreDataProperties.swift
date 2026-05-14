//
//  EmotionEntryEntity+CoreDataProperties.swift
//  lifeisgame
//
//  Created by Codex on 08.05.2026.
//

import Foundation
import CoreData

extension EmotionEntryEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EmotionEntryEntity> {
        NSFetchRequest<EmotionEntryEntity>(entityName: "EmotionEntryEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var emotionName: String?
    @NSManaged public var sfSymbol: String?
    @NSManaged public var reason: String?
    @NSManaged public var intensity: Int16
    @NSManaged public var dayDate: Date?
    @NSManaged public var createdAt: Date?
    @NSManaged public var owner: UserEntity?
}
