//
//  Persistence.swift
//  Example
//
//  Created by Kamaal M Farah on 14/11/2022.
//

import CoreData
import Dispatch
import ManuallyManagedObject

struct PersistenceController {
    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        let persistentContainerBuilder = _PersistentContainerBuilder(
            entities: [Item.entity, Child.entity],
            relationships: Item.relationships + Child.relationships,
            preview: inMemory)
        container = persistentContainerBuilder.make(withName: "Example")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for _ in 0..<10 {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
        }
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
}
