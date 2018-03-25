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
        .package(url: "https://github.com/vapor/core.git", from: "3.0.0-rc.2"),

        // 💻 APIs for creating interactive CLI tools.
        .package(url: "https://github.com/vapor/console.git", from: "3.0.0-rc.2"),

        // 🗄 Core services for creating database integrations.
        .package(url: "https://github.com/rafiki270/database-kit.git", .branch("master")),

        // 📦 Dependency injection / inversion of control framework.
        .package(url: "https://github.com/vapor/service.git", from: "1.0.0-rc.2"),
    ],
    targets: [
        .target(name: "Fluent", dependencies: ["Async", "CodableKit", "Console", "Command", "DatabaseKit", "Logging", "Service"]),
        .testTarget(name: "FluentTests", dependencies: ["FluentBenchmark", "FluentSQL"]),
        .target(name: "FluentBenchmark", dependencies: ["Fluent", "FluentSQL"]),
        .target(name: "FluentSQL", dependencies: ["Fluent", "SQL"]),
    ]
)
