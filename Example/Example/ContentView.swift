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
                    NavigationLink(destination: { ChildView(parent: item) }) {
                        Text(dateFormatter.string(from: item.timestamp))
                    }
                }
                .onDelete(perform: deleteItem)
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
                Text("No children yet")
            }
            ForEach(parent.childrenArray, id: \.id) { item in
                Text(dateFormatter.string(from: item.timestamp))
            }
        }
        .navigationTitle("Child")
        #if os(iOS)
        .toolbar { ToolbarItem(placement: .navigationBarTrailing) { toolbarView } }
        #else
        .toolbar { toolbarView }
        #endif
    }

    private var toolbarView: some View {
        Button(action: addChild) {
            Image(systemName: "plus")
                .bold()
        }
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
