//
//  ManuallyManagedObjectTests.swift
//
//
//  Created by Kamaal M Farah on 14/11/2022.
//

import XCTest
@testable import ManuallyManagedObject

final class ManuallyManagedObjectTests: XCTestCase {
    let viewContext = PersistenceController.shared.container.viewContext

    override func tearDownWithError() throws {
        try Item.clear(in: viewContext)
    }

    func testItemGetsCreated() throws {
        let item = Item(context: viewContext)
        item.timestamp = Date()
        item.id = UUID()
        try viewContext.save()

        let items = try Item.list(from: viewContext)
        XCTAssertEqual(items.count, 1)
    }

    func testItemIsDeleted() throws {
        let item = Item(context: viewContext)
        item.timestamp = Date()
        item.id = UUID()
        try viewContext.save()

        try item.delete()
        let items = try Item.list(from: viewContext)
        XCTAssert(items.isEmpty)
    }

    func testCorrectItemsGetFiltered() throws {
        let item1 = Item(context: viewContext)
        item1.timestamp = Date()
        item1.id = UUID()
        let item2 = Item(context: viewContext)
        item2.timestamp = Date()
        item2.id = UUID()
        let item3 = Item(context: viewContext)
        item3.timestamp = Date()
        item3.id = UUID()
        try viewContext.save()

        let itemsToSearchFor = [item1, item3]
        let predicate = NSPredicate(format: "id IN %@", itemsToSearchFor.map({ NSString(string: $0.id.uuidString) }))
        let limit = 3
        let items = try Item.filter(by: predicate, limit: limit, from: viewContext)

        XCTAssertEqual(items.count, itemsToSearchFor.count)
        XCTAssertNotEqual(items.count, limit)
        XCTAssert(items.allSatisfy({ itemsToSearchFor.contains($0) }))
    }

    func testFoundItem() throws {
        let item1 = Item(context: viewContext)
        item1.timestamp = Date()
        item1.id = UUID()
        let item2 = Item(context: viewContext)
        item2.timestamp = Date()
        item2.id = UUID()
        let item3 = Item(context: viewContext)
        item3.timestamp = Date()
        item3.id = UUID()
        try viewContext.save()

        let predicate = NSPredicate(format: "id = %@", NSString(string: item2.id.uuidString))
        let foundItem = try Item.find(by: predicate, from: viewContext)

        XCTAssertEqual(foundItem, item2)
    }

    func testItemNotFound() throws {
        let item1 = Item(context: viewContext)
        item1.timestamp = Date()
        item1.id = UUID()
        let item2 = Item(context: viewContext)
        item2.timestamp = Date()
        item2.id = UUID()
        let item3 = Item(context: viewContext)
        item3.timestamp = Date()
        item3.id = UUID()
        try viewContext.save()

        let predicate = NSPredicate(format: "id = %@", NSString(string: UUID().uuidString))
        let foundItem = try Item.find(by: predicate, from: viewContext)

        XCTAssertNil(foundItem)
    }
}
