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
        let model = NSManagedObjectModel()

        let childEntity = NSEntityDescription()
        childEntity.name = "Child"
        childEntity.managedObjectClassName = "Child"
        let childIDAttribute = NSAttributeDescription()
        childIDAttribute.name = "id"
        childIDAttribute.attributeType = .UUIDAttributeType
        childIDAttribute.isOptional = false
        let childTimestampAttribute = NSAttributeDescription()
        childTimestampAttribute.name = "timestamp"
        childTimestampAttribute.attributeType = .dateAttributeType
        childTimestampAttribute.isOptional = false
        let parentRelationship = NSRelationshipDescription()
        parentRelationship.name = "parent"
        parentRelationship.maxCount = 1
        parentRelationship.isOptional = false

        let itemEntity = NSEntityDescription()
        itemEntity.name = "Item"
        itemEntity.managedObjectClassName = "Item"
        let itemIDAttribute = NSAttributeDescription()
        itemIDAttribute.name = "id"
        itemIDAttribute.attributeType = .UUIDAttributeType
        itemIDAttribute.isOptional = false
        let itemTimestampAttribute = NSAttributeDescription()
        itemTimestampAttribute.name = "timestamp"
        itemTimestampAttribute.attributeType = .dateAttributeType
        itemTimestampAttribute.isOptional = false
        let childrenRelationship = NSRelationshipDescription()
        childrenRelationship.name = "children"
        childrenRelationship.isOptional = true
        childrenRelationship.maxCount = 0

        parentRelationship.destinationEntity = itemEntity
        parentRelationship.inverseRelationship = childrenRelationship
        childrenRelationship.destinationEntity = childEntity
        childrenRelationship.inverseRelationship = parentRelationship

        childEntity.properties = [
            childIDAttribute,
            childTimestampAttribute,
            parentRelationship,
        ]

        itemEntity.properties = [
            itemIDAttribute,
            itemTimestampAttribute,
            childrenRelationship,
        ]

        model.entities = [
            childEntity,
            itemEntity,
        ]

        container = NSPersistentContainer(name: "Example", managedObjectModel: model)
//        let persistentContainerBuilder = PersistentContainerBuilder(
//            entities: [Item.entity, Child.entity],
//            relationships: Item.relationships + Child.relationships,
//            preview: inMemory)
//        container = persistentContainerBuilder.make(withName: "Example")
        self.container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        self.container.viewContext.automaticallyMergesChangesFromParent = true
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
