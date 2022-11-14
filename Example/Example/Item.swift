//
//  Item.swift
//  Example
//
//  Created by Kamaal M Farah on 14/11/2022.
//

import CoreData
import ManuallyManagedObject

@objc(Item)
public class Item: NSManagedObject, ManuallyManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var timestamp: Date

    public static let properties: [ManagedObjectPropertyConfiguration] = [
        .init(name: \Item.id, type: .uuid, isOptional: false),
        .init(name: \Item.timestamp, type: .date, isOptional: false),
    ]
}
