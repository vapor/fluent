// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "Fluent",
    products: [
        .library(name: "Fluent", targets: ["Fluent"]),
        .library(name: "FluentTester", targets: ["FluentTester"])
    ],
    dependencies: [
        // Data structure for converting between multiple representations
        .package(url: "https://github.com/vapor/node.git", .upToNextMajor(from: "2.1.0")),

        // Useful helpers and extensions
        .package(url: "https://github.com/vapor/core.git", .upToNextMajor(from: "2.1.2")),

        // Random number generation
        .package(url: "https://github.com/vapor/random.git", .upToNextMajor(from: "1.1.0")),

        // In memory Database
        .package(url: "https://github.com/vapor/sqlite.git", .upToNextMajor(from: "2.0.0")),
    ],
    targets: [
        .target(name: "Fluent", dependencies: ["Core", "Node", "Random", "SQLite"]),
        .testTarget(name: "FluentTests", dependencies: ["Fluent"]),
        .target(name: "FluentTester", dependencies: ["Fluent"]),
        .testTarget(name: "FluentTesterTests", dependencies: ["FluentTester"]),
    ]
)
