//
//  ManuallyManagedObject.swift
//
//
//  Created by Kamaal M Farah on 14/11/2022.
//

import CoreData

/// Protocol to use when implementing `NSManagedObject`'s without using Xcode's GUI.
///
/// Example usage:
///
/// ```swift
/// @objc(Item)
/// public class Item: NSManagedObject, ManuallyManagedObject {
///     @NSManaged public var id: UUID
///     @NSManaged public var timestamp: Date
///
///     public static let properties: [ManagedObjectPropertyConfiguration] = [
///         .init(name: \Item.id, type: .uuid, isOptional: false),
///         .init(name: \Item.timestamp, type: .date, isOptional: false),
///     ]
/// }
/// ```
///
/// How to initialize a manually managed objects in your application?
///
/// ```swift
/// class PersistenceController {
///     let container: NSPersistentContainer
///
///     init() {
///         let model = NSManagedObjectModel()
///         model.entities = [
///             Item.entity,
///             // All your other managed object entities.
///         ]
///         container = NSPersistentContainer(name: "<ContainerName>", managedObjectModel: model)
///
///         // All the other Persistence configurations.
///     }
/// }
/// ```
///
public protocol ManuallyManagedObject: NSManagedObject {
    /// Managed objects properties.
    static var properties: [ManagedObjectField] { get }
}

extension ManuallyManagedObject {
    /// Deletes the managed object.
    /// - Parameter save: whether to commit deletion or not.
    public func delete(save: Bool = true) throws {
        guard let context = managedObjectContext else { return }

        context.delete(self)

        if save {
            try context.save()
        }
    }

    /// A description of an entity in Core Data.
    public static var entity: NSEntityDescription {
        // Create the entity
        let entity = NSEntityDescription()
        entity.name = entityName
        entity.managedObjectClassName = entityName

        // Create the attributes
        entity.properties = properties.compactMap(\.property)

        return entity
    }

    ///  Makes a `NSFetchRequest` for the managed object.
    /// - Returns: A description of search criteria used to retrieve data from a persistent store.
    public static func fetchRequest() -> NSFetchRequest<Self> {
        NSFetchRequest<Self>(entityName: entityName)
    }

    /// Lists all items in CoreData store.
    /// - Parameter context: An object space to manipulate and track changes to managed objects.
    /// - Returns: All items in CoreData store.
    public static func list(from context: NSManagedObjectContext) throws -> [Self] {
        try filter(by: NSPredicate(value: true), from: context)
    }

    /// Filters items in CoreData store.
    /// - Parameters:
    ///   - predicate: Query to filter the items on.
    ///   - context: An object space to manipulate and track changes to managed objects.
    /// - Returns: Filtered items in CoreData store.
    public static func filter(by predicate: NSPredicate, from context: NSManagedObjectContext) throws -> [Self] {
        try filter(by: predicate, limit: nil, from: context)
    }

    /// Filters items in CoreData store.
    /// - Parameters:
    ///   - predicate: Query to filter the items on.
    ///   - limit: The maximum amount of items to return.
    ///   - context: An object space to manipulate and track changes to managed objects.
    /// - Returns: Filtered items in CoreData store.
    public static func filter(
        by predicate: NSPredicate,
        limit: Int?,
        from context: NSManagedObjectContext) throws -> [Self] {
            let request = fetchRequest()
            request.predicate = predicate
            if let limit = limit {
                request.fetchLimit = limit
            }
            return try context.fetch(request)
        }

    /// Finds a single item based in the query.
    /// - Parameters:
    ///   - predicate: Query to find the item on.
    ///   - context: An object space to manipulate and track changes to managed objects.
    /// - Returns: An found item in CoreData store.
    public static func find(by predicate: NSPredicate, from context: NSManagedObjectContext) throws -> Self? {
        try filter(by: predicate, limit: 1, from: context).first
    }

    static func clear(in context: NSManagedObjectContext) throws {
        guard let request = fetchRequest() as? NSFetchRequest<NSFetchRequestResult> else { return }

        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        try context.execute(deleteRequest)
        try context.save()
    }

    static var entityName: String {
        String(describing: Self.self)
    }
}
