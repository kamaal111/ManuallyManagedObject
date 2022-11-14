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

    override func setUpWithError() throws {
        try Item.clear(in: viewContext)
    }

    override func tearDownWithError() throws {
        try Item.clear(in: viewContext)
    }

    func testItemGetsCreated() throws {
        let item = Item(context: viewContext)
        item.timestamp = Date()
        item.id = UUID()

        let items = try Item.list(from: viewContext)
        XCTAssertEqual(items.count, 1)
    }

    func testItemIsDeleted() throws {
        let item = Item(context: viewContext)
        item.timestamp = Date()
        item.id = UUID()

        try item.delete()
        let items = try Item.list(from: viewContext)
        XCTAssert(items.isEmpty)
    }
}
