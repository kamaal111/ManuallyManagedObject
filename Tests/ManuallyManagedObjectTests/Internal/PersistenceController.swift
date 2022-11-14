//
//  PersistenceController.swift
//  
//
//  Created by Kamaal M Farah on 14/11/2022.
//

import CoreData
import ManuallyManagedObject

struct PersistenceController {
    let container: NSPersistentContainer

    init() {
        let model = NSManagedObjectModel()
        model.entities = PersistenceController.entities
        container = NSPersistentContainer(name: "ManuallyManagedObjectTests", managedObjectModel: model)
        container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    private static let entities: [NSEntityDescription] = [
        Item.entity
    ]

    static let shared = PersistenceController()
}

@objc(Item)
public class Item: NSManagedObject, ManuallyManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var timestamp: Date

    public static let properties: [ManagedObjectPropertyConfiguration] = [
        .init(name: \Item.id, type: .uuid, isOptional: false),
        .init(name: \Item.timestamp, type: .date, isOptional: false),
    ]
}
