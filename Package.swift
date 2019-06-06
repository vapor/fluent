// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "fluent",
    products: [
        .library(name: "Fluent", targets: ["Fluent"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/fluent-kit.git", from: "1.0.0-alpha"),
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0-alpha"),
    ],
    targets: [
        .target(name: "Fluent", dependencies: ["FluentKit", "Vapor"]),
        .testTarget(name: "FluentTests", dependencies: ["Fluent"]),
    ]
)
