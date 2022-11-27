//
//  ManagedObjectField.swift
//  
//
//  Created by Kamaal M Farah on 27/11/2022.
//

import CoreData
import Foundation

/// Base class to configure a managed object entity field.
public class ManagedObjectField {
    /// Model entity property.
    public var property: NSPropertyDescription?

    /// Basic initializer.
    public init() { }
}
