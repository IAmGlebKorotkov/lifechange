//
//  AchievementEntity+CoreDataProperties.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 12.05.2026.
//

import Foundation
import CoreData

extension AchievementEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AchievementEntity> {
        NSFetchRequest<AchievementEntity>(entityName: "AchievementEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var code: String?
    @NSManaged public var kind: String?
    @NSManaged public var icon: String?
    @NSManaged public var title: String?
    @NSManaged public var goal: String?
    @NSManaged public var targetValue: Int32
    @NSManaged public var currentValue: Int32
    @NSManaged public var state: String?
    @NSManaged public var cellHeight: Double
    @NSManaged public var sortOrder: Int16
    @NSManaged public var unlockedAt: Date?
    @NSManaged public var openedAt: Date?
    @NSManaged public var createdAt: Date?
    @NSManaged public var owner: UserEntity?
}
