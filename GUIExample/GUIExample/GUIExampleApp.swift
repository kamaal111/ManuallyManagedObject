//
//  GUIExampleApp.swift
//  GUIExample
//
//  Created by Kamaal M Farah on 27/11/2022.
//

import SwiftUI

@main
struct GUIExampleApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
