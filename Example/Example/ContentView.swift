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
                    EmptyItemsView(itemName: "items")
                }
                ForEach(items, id: \.id) { item in
                    NavigationLink(destination: { ChildView(parent: item) }) {
                        TimestampView(time: item.timestamp)
                            .foregroundColor(.accentColor)
                    }
                }
                .onDelete(perform: deleteItem)
            }
            .navigationTitle("MMO")
            #if os(iOS)
            .toolbar { ToolbarItem(placement: .navigationBarTrailing) { AddButton(action: addItem) } }
            #else
            .toolbar { AddButton(action: addItem) }
            #endif
        }
    }

    private func deleteItem(_ indices: IndexSet) {
        for index in indices {
            do {
                try items[index].delete()
            } catch {
                print("error", error)
            }
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

struct ChildView: View {
    @Environment(\.managedObjectContext) private var viewContext

    let parent: Item

    var body: some View {
        List {
            if parent.childrenArray.isEmpty {
                EmptyItemsView(itemName: "children")
            }
            ForEach(parent.childrenArray, id: \.id) { item in
                TimestampView(time: item.timestamp)
            }
        }
        .navigationTitle("Child")
        #if os(iOS)
        .toolbar { ToolbarItem(placement: .navigationBarTrailing) { AddButton(action: addChild) } }
        #else
        .toolbar { AddButton(action: addChild) }
        #endif
    }

    private func addChild() {
        let child = Child(context: viewContext)
        child.timestamp = Date()
        child.id = UUID()
        child.parent = parent

        do {
            try parent.addChild(child)
        } catch {
            print("error", error)
            return
        }
    }
}

struct EmptyItemsView: View {
    let itemName: String

    var body: some View {
        Text("No \(itemName) yet")
    }
}

struct TimestampView: View {
    let time: Date

    var body: some View {
        Text(dateFormatter.string(from: time))
    }
}

struct AddButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .bold()
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
