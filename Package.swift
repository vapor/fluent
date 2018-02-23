// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "Fluent",
    products: [
        .library(name: "Fluent", targets: ["Fluent"]),
        .library(name: "FluentBenchmark", targets: ["FluentBenchmark"]),
        .library(name: "FluentSQL", targets: ["FluentSQL"]),
        .library(name: "FluentSQLite", targets: ["FluentSQLite"]),
        .library(name: "SQLite", targets: ["SQLite"]),
    ],
    dependencies: [
        // ⏱ Promises and reactive-streams in Swift built for high-performance and scalability.
        .package(url: "https://github.com/vapor/async.git", from: "1.0.0-rc"),

        // 🌎 Utility package containing tools for byte manipulation, Codable, OS APIs, and debugging.
        .package(url: "https://github.com/vapor/core.git", from: "3.0.0-rc"),

        // 💻 APIs for creating interactive CLI tools.
        .package(url: "https://github.com/vapor/console.git", from: "3.0.0-rc"),

        // 🗄 Core services for creating database integrations.
        .package(url: "https://github.com/vapor/database-kit.git", from: "1.0.0-rc"),

        // 📦 Dependency injection / inversion of control framework.
        .package(url: "https://github.com/vapor/service.git", from: "1.0.0-rc"),
    ],
    targets: [
        .target(name: "CSQLite"),
        .target(name: "Fluent", dependencies: ["Async", "CodableKit", "Console", "DatabaseKit", "Service"]),
        .testTarget(name: "FluentTests", dependencies: ["FluentBenchmark", "FluentSQLite", "SQLite"]),
        .target(name: "FluentBenchmark", dependencies: ["Fluent"]),
        .target(name: "FluentSQL", dependencies: ["Fluent", "SQL"]),
        .target(name: "FluentSQLite", dependencies: ["Fluent", "FluentSQL", "SQLite"]),
        .target(name: "SQLite", dependencies: ["Bits", "CodableKit", "CSQLite", "Debugging"]),
        .testTarget(name: "SQLiteTests", dependencies: ["SQLite"]),
    ]
)
