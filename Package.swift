// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "fluent",
    products: [
        .library(name: "Fluent", targets: ["Fluent"]),
        .library(name: "FluentBenchmark", targets: ["FluentBenchmark"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git", from: "1.0.0"),
        .package(url: "https://github.com/vapor/postgresql.git", .branch("2")),
    ],
    targets: [
        .target(name: "Fluent", dependencies: ["NIO"]),
        .testTarget(name: "FluentTests", dependencies: ["FluentBenchmark"]),
        .target(name: "FluentBenchmark", dependencies: ["Fluent", "NIO"]),
        .target(name: "FluentPostgres", dependencies: ["Fluent", "PostgresKit"]),
        .testTarget(name: "FluentPostgresTests", dependencies: ["FluentPostgres", "FluentBenchmark"]),
    ]
)
