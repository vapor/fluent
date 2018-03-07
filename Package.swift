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
        .package(url: "https://github.com/vapor/core.git", .branch("nio")),

        // 💻 APIs for creating interactive CLI tools.
        .package(url: "https://github.com/vapor/console.git", .branch("nio")),

        // 🗄 Core services for creating database integrations.
        .package(url: "https://github.com/vapor/database-kit.git", .branch("nio")),

        // 📦 Dependency injection / inversion of control framework.
        .package(url: "https://github.com/vapor/service.git", .branch("nio")),
    ],
    targets: [
        .target(name: "Fluent", dependencies: ["Async", "CodableKit", "Console", "DatabaseKit", "Service"]),
        .testTarget(name: "FluentTests", dependencies: ["FluentBenchmark", "FluentSQL"]),
        .target(name: "FluentBenchmark", dependencies: ["Fluent"]),
        .target(name: "FluentSQL", dependencies: ["Fluent", "SQL"]),
    ]
)
