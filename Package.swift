// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ManuallyManagedObject",
    products: [
        .library(
            name: "ManuallyManagedObject",
            targets: ["ManuallyManagedObject"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "ManuallyManagedObject",
            dependencies: []),
        .testTarget(
            name: "ManuallyManagedObjectTests",
            dependencies: ["ManuallyManagedObject"]),
    ]
)
