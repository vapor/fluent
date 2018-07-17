// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "Fluent",
    products: [
        .library(name: "Fluent", targets: ["Fluent"]),
        .library(name: "FluentSQL", targets: ["FluentSQL"]),
        .library(name: "FluentBenchmark", targets: ["FluentBenchmark"]),
    ],
    dependencies: [
        // 🌎 Utility package containing tools for byte manipulation, Codable, OS APIs, and debugging.
        .package(url: "https://github.com/vapor/core.git", from: "3.4.0"),

        // 💻 APIs for creating interactive CLI tools.
        .package(url: "https://github.com/vapor/console.git", from: "3.0.0"),

        // 🗄 Core services for creating database integrations.
        .package(url: "https://github.com/vapor/database-kit.git", from: "1.2.0"),

        // 📦 Dependency injection / inversion of control framework.
        .package(url: "https://github.com/vapor/service.git", from: "1.0.0"),
        
        // *️⃣ Build SQL queries in Swift. Extensible, protocol-based design that supports DQL, DML, and DDL.
        .package(url: "https://github.com/vapor/sql.git", from: "2.0.0"),
    ],
    targets: [
        .target(name: "Fluent", dependencies: ["Async", "Console", "Command", "Core", "DatabaseKit", "Logging", "Service"]),
        .target(name: "FluentSQL", dependencies: ["Fluent", "SQL"]),
        .testTarget(name: "FluentTests", dependencies: ["FluentBenchmark"]),
        .target(name: "FluentBenchmark", dependencies: ["Fluent"]),
    ]
)
