// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "Fluent",
    products: [
        .library(name: "Fluent", targets: ["Fluent"]),
        .library(name: "FluentSQL", targets: ["FluentSQL"]),
        .library(name: "FluentSQLite", targets: ["FluentSQLite"]),
        .library(name: "SQL", targets: ["SQL"]),
        .library(name: "SQLite", targets: ["SQLite"]),
    ],
    dependencies: [
        // Swift Promises, Futures, and Streams.
        .package(url: "https://github.com/vapor/async.git", .branch("beta")),

        // Core extensions, type-aliases, and functions that facilitate common tasks.
        .package(url: "https://github.com/vapor/core.git", .branch("beta")),

        // Service container and configuration system.
        .package(url: "https://github.com/vapor/service.git", .branch("beta")),
    ],
    targets: [
        .target(name: "CSQLite"),
        .target(name: "Fluent", dependencies: ["Async", "Service"]),
        .testTarget(name: "FluentTests", dependencies: ["FluentBenchmark", "FluentSQLite", "SQLite"]),
        .target(name: "FluentBenchmark", dependencies: ["Fluent"]),
        .target(name: "FluentSQL", dependencies: ["Fluent", "SQL"]),
        .target(name: "FluentSQLite", dependencies: ["Fluent", "FluentSQL", "SQLite"]),
        .target(name: "SQL"),
        .testTarget(name: "SQLTests", dependencies: ["SQL"]),
        .target(name: "SQLite", dependencies: ["Bits", "CodableKit", "CSQLite", "Debugging"]),
        .testTarget(name: "SQLiteTests", dependencies: ["SQLite"]),
    ]
)
