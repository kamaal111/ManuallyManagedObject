//
//  PersistentContainerBuilder.swift
//  
//
//  Created by Kamaal M Farah on 16/11/2022.
//

import CoreData
import Foundation

public struct _PersistentContainerBuilder {
    public let entities: [NSEntityDescription]
    public let relationships: [_RelationshipConfiguration]
    public let preview: Bool

    public init(entities: [NSEntityDescription], relationships: [_RelationshipConfiguration] = [], preview: Bool) {
        self.entities = entities
        self.relationships = relationships
        self.preview = preview
    }

    public init(entities: [NSEntityDescription], relationships: [_RelationshipConfiguration] = []) {
        self.init(entities: entities, relationships: relationships, preview: false)
    }

    public func make(withName name: String) -> NSPersistentContainer {
        let container = NSPersistentContainer(name: name, managedObjectModel: model)
        if preview {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        return container
    }

    private var entitiesWithRelationships: [NSEntityDescription] {
        let entitiesByName: [String: NSEntityDescription] = entities
            .reduce([:]) { result, entity in
                guard let name = entity.name else { return result }

                var result = result
                result[name] = entity
                return result
            }

        let relationshipsWithDestinationEntities: [RelationshipContainer] = relationships
            .compactMap { relationship in
                guard let entity = entitiesByName[relationship.destinationEntityName] else { return nil }

                let relationshipWithDestinationEntity = relationship.setDestinationEntity(entity)

                guard let nsRelationship = relationshipWithDestinationEntity.property as? NSRelationshipDescription
                else { return nil }

                return RelationshipContainer(nsRelationship: nsRelationship,
                                             configuration: relationshipWithDestinationEntity)
            }

        for relationshipsWithDestinationEntity in relationshipsWithDestinationEntities {
            // Find inverse entity
            let inverseEntityRelationship = relationshipsWithDestinationEntities
                .first {
                    $0.configuration.name == relationshipsWithDestinationEntity.configuration.inverseRelationshipName
                }

            guard let inverseEntityRelationship else { continue }

            let nsInverseEntityRelationship = inverseEntityRelationship.nsRelationship
            let completeRelationship = relationshipsWithDestinationEntity.nsRelationship
            // Set inverse relationship to relationship
            completeRelationship.inverseRelationship = nsInverseEntityRelationship

            // Set `completeRelationship` as property to inverse entity
            entitiesByName[relationshipsWithDestinationEntity.configuration.inverseRelationshipEntityName]?.properties
                .append(completeRelationship)
        }

        return Array(entitiesByName.values)
    }

    private var model: NSManagedObjectModel {
        let model = NSManagedObjectModel()
        model.entities = entitiesWithRelationships
        return model
    }
}

fileprivate struct RelationshipContainer {
    let nsRelationship: NSRelationshipDescription
    let configuration: _RelationshipConfiguration
}
