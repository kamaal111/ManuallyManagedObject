//
//  ExampleApp.swift
//  Example
//
//  Created by Kamaal M Farah on 14/11/2022.
//

import SwiftUI

@main
struct ExampleApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
