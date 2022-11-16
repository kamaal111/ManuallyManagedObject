//
//  RelationshipConfiguration.swift
//  
//
//  Created by Kamaal M Farah on 16/11/2022.
//

import CoreData
import Foundation

public struct RelationshipConfiguration: Hashable {
    public let name: String
    public let destinationEntityName: String
    public let inverseRelationshipName: String
    public let isOptional: Bool
    public let relationshipType: RelationshipType
    private(set) var destinationEntity: NSEntityDescription?

    public init(
        name: String,
        destinationEntity: String,
        inverseRelationshipName: String,
        isOptional: Bool,
        relationshipType: RelationshipType) {
            self.name = name
            self.destinationEntityName = destinationEntity
            self.inverseRelationshipName = inverseRelationshipName
            self.isOptional = isOptional
            self.relationshipType = relationshipType
        }

    public init<Destination: ManuallyManagedObject>(
        name: String,
        destinationEntity: Destination.Type,
        inverseRelationshipName: String,
        isOptional: Bool,
        relationshipType: RelationshipType) {
            self.init(
                name: name,
                destinationEntity: destinationEntity.entityName,
                inverseRelationshipName: inverseRelationshipName,
                isOptional: isOptional,
                relationshipType: relationshipType)
        }

    var nsRelationship: NSRelationshipDescription {
        let relationship = NSRelationshipDescription()
            .setRelationshipType(with: relationshipType)
        relationship.name = name
        relationship.isOptional = isOptional
        relationship.destinationEntity = destinationEntity
        return relationship
    }

    func setDestinationEntity(_ destinationEntity: NSEntityDescription) -> RelationshipConfiguration {
        var configuration = RelationshipConfiguration(
            name: name,
            destinationEntity: destinationEntityName,
            inverseRelationshipName: inverseRelationshipName,
            isOptional: isOptional,
            relationshipType: relationshipType)
        configuration.destinationEntity = destinationEntity
        return configuration
    }
}

public enum RelationshipType {
    case toMany
    case toOne
}

extension NSRelationshipDescription {
    func setRelationshipType(with type: RelationshipType) -> NSRelationshipDescription {
        minCount = 0
        switch type {
        case .toMany:
            maxCount = 0
        case .toOne:
            maxCount = 1
        }
        return self
    }
}
