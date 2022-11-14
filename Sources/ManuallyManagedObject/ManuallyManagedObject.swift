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
    static var properties: [ManagedObjectPropertyConfiguration] { get }
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
        entity.properties = properties.map(\.attribute)

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
        try context.fetch(fetchRequest())
    }

    static func clear(in context: NSManagedObjectContext) throws {
        guard let request = fetchRequest() as? NSFetchRequest<NSFetchRequestResult> else { return }

        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        try context.execute(deleteRequest)
        try context.save()
    }

    private static var entityName: String {
        String(describing: Self.self)
    }
}

/// Property configuration handled by ``ManuallyManagedObject``.
public struct ManagedObjectPropertyConfiguration {
    /// Property name.
    public let name: String
    /// Property type.
    public let type: PropertyTypes
    /// Wether or not the object is optional.
    public let isOptional: Bool

    /// Memberwise initializer.
    /// - Parameters:
    ///   - name: Property name.
    ///   - type: Property type.
    ///   - isOptional: Wether or not the object is optional.
    public init(name: String, type: PropertyTypes, isOptional: Bool) {
        self.name = name
        self.type = type
        self.isOptional = isOptional
    }

    /// Initialize with managed objects keypath.
    /// - Parameters:
    ///   - name: Property name.
    ///   - type: Property type.
    ///   - isOptional: Wether or not the object is optional.
    public init<Root: ManuallyManagedObject, Value>(name: KeyPath<Root, Value>, type: PropertyTypes, isOptional: Bool) {
        self.init(name: NSExpression(forKeyPath:  name).keyPath, type: type, isOptional: isOptional)
    }

    /// The managed objects property type represented in a enum.
    public enum PropertyTypes {
        /// `Date` type.
        case date
        /// `UUID` type.
        case uuid
        /// `URL` type.
        case url
        /// `Data` type.
        case data
        /// `Bool` type.
        case bool
        /// `String` type.
        case string
        /// `Float` type.
        case float
        /// `Doublie` type.
        case double
        /// `Int64` type.
        case int64
        /// `Int32` type.
        case int32
        /// `Int16` type.
        case int16

        fileprivate var nsAttributeType: NSAttributeType {
            switch self {
            case .date:
                return .dateAttributeType
            case .uuid:
                return .UUIDAttributeType
            case .url:
                return .URIAttributeType
            case .data:
                return .binaryDataAttributeType
            case .bool:
                return .booleanAttributeType
            case .string:
                return .stringAttributeType
            case .float:
                return .floatAttributeType
            case .double:
                return .doubleAttributeType
            case .int64:
                return .integer64AttributeType
            case .int32:
                return .integer32AttributeType
            case .int16:
                return .integer16AttributeType
            }
        }
    }

    fileprivate var attribute: NSAttributeDescription {
        let attribute = NSAttributeDescription()
        attribute.name = name
        attribute.attributeType = type.nsAttributeType
        attribute.isOptional = isOptional
        return attribute
    }
}
