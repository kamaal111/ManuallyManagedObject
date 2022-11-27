//
//  Item.swift
//  Example
//
//  Created by Kamaal M Farah on 14/11/2022.
//

import CoreData
import ManuallyManagedObject

@objc(Item)
class Item: NSManagedObject, ManuallyManagedObject, Identifiable {
    @NSManaged var id: UUID
    @NSManaged var timestamp: Date
    @NSManaged var children: NSSet?

    var childrenArray: [Child] {
        children?.allObjects as? [Child] ?? []
    }

    func addChild(_ child: Child, save: Bool) throws {
        children = NSSet(array: childrenArray + [child])

        if save {
            try managedObjectContext?.save()
        }
    }

    func addChild(_ child: Child) throws {
        try addChild(child, save: true)
    }

    static let properties: [ManagedObjectField] = [
        ManagedObjectPropertyConfiguration(name: \Item.id, type: .uuid, isOptional: false),
        ManagedObjectPropertyConfiguration(name: \Item.timestamp, type: .date, isOptional: false),
    ]

    static let relationships: [RelationshipConfiguration] = [
//        .init(
//            name: "parent",
//            destinationEntity: Item.self,
//            inverseRelationshipName: "children",
//            isOptional: true,
//            relationshipType: .toMany)
    ]
}

@objc(Child)
class Child: NSManagedObject, ManuallyManagedObject, Identifiable {
    @NSManaged var id: UUID
    @NSManaged var timestamp: Date
    @NSManaged var parent: Item

    static let properties: [ManagedObjectField] = [
        ManagedObjectPropertyConfiguration(name: \Child.id, type: .uuid, isOptional: false),
        ManagedObjectPropertyConfiguration(name: \Child.timestamp, type: .date, isOptional: false),
    ]

    static let relationships: [RelationshipConfiguration] = [
//        .init(
//            name: "children",
//            destinationEntity: Child.self,
//            inverseRelationshipName: "parent",
//            isOptional: false,
//            relationshipType: .toOne)
    ]
}
