//
//  PersistenceController.swift
//  lifeisgame
//
//  Created by Gleb Korotkov on 22.04.2026.
//

import CoreData

final class PersistenceController {

    static let shared = PersistenceController()

    let container: NSPersistentContainer

    private init() {
        container = NSPersistentContainer(name: "lifeisgame")
        container.loadPersistentStores { _, error in
            if let error {
                fatalError("CoreData failed to load: \(error)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    var context: NSManagedObjectContext {
        container.viewContext
    }

    func save() {
        let ctx = container.viewContext
        guard ctx.hasChanges else { return }
        do {
            try ctx.save()
        } catch {
            ctx.rollback()
        }
    }

    func newBackgroundContext() -> NSManagedObjectContext {
        container.newBackgroundContext()
    }
}
