// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "Fluent",
    products: [
        .library(name: "Fluent", targets: ["Fluent"]),
        .library(name: "FluentBenchmark", targets: ["FluentBenchmark"]),
        .library(name: "FluentSQL", targets: ["FluentSQL"]),
    ],
    dependencies: [
        // 🌎 Utility package containing tools for byte manipulation, Codable, OS APIs, and debugging.
        .package(url: "https://github.com/vapor/core.git", from: "3.0.0"),

        // 💻 APIs for creating interactive CLI tools.
        .package(url: "https://github.com/vapor/console.git", from: "3.0.0"),

        // 🗄 Core services for creating database integrations.
        .package(url: "https://github.com/vapor/database-kit.git", from: "1.0.0"),

        // 📦 Dependency injection / inversion of control framework.
        .package(url: "https://github.com/vapor/service.git", from: "1.0.0"),

        // *️⃣ Build SQL queries in Swift. 
        .package(url: "https://github.com/vapor/sql.git", from: "1.0.0"),
    ],
    targets: [
        .target(name: "Fluent", dependencies: ["Async", "Console", "Command", "Core", "DatabaseKit", "Logging", "Service"]),
        .testTarget(name: "FluentTests", dependencies: ["FluentBenchmark", "FluentSQL"]),
        .target(name: "FluentBenchmark", dependencies: ["Fluent", "FluentSQL"]),
        .target(name: "FluentSQL", dependencies: ["Fluent", "SQL"]),
    ]
)
