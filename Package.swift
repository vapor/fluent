// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "Fluent",
    products: [
        .library(name: "Fluent", targets: ["Fluent"]),
        .library(name: "FluentBenchmark", targets: ["FluentBenchmark"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git", from: "1.0.0"),
    ],
    targets: [
        .target(name: "Fluent", dependencies: ["NIO"]),
        .testTarget(name: "FluentTests", dependencies: ["FluentBenchmark"]),
        .target(name: "FluentBenchmark", dependencies: ["Fluent", "NIO"]),
    ]
)
