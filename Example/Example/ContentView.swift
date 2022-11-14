//
//  ContentView.swift
//  Example
//
//  Created by Kamaal M Farah on 14/11/2022.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: false)], animation: .default)
    private var items: FetchedResults<Item>

    var body: some View {
        NavigationStack {
            List {
                if items.isEmpty {
                    Text("No items yet")
                }
                ForEach(items, id: \.id) { item in
                    Text(dateFormatter.string(from: item.timestamp))
                }
            }
            .navigationTitle("MMO")
            #if os(iOS)
            .toolbar { ToolbarItem(placement: .navigationBarTrailing) { toolbarView } }
            #else
            .toolbar { toolbarView }
            #endif
        }
        .frame(minWidth: 300, minHeight: 300)
    }

    private var toolbarView: some View {
        Button(action: addItem) {
            Image(systemName: "plus")
                .bold()
        }
    }

    private func addItem() {
        let item = Item(context: viewContext)
        item.timestamp = Date()
        item.id = UUID()

        do {
            try viewContext.save()
        } catch {
            print("error", error)
            return
        }
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
