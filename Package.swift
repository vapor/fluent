// swift-tools-version:5.8
import PackageDescription

let package = Package(
    name: "fluent",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .watchOS(.v6),
        .tvOS(.v13),
    ],
    products: [
        .library(name: "Fluent", targets: ["Fluent"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/fluent-kit.git", from: "1.48.4"),
        .package(url: "https://github.com/vapor/vapor.git", from: "4.101.0"),
    ],
    targets: [
        .target(
            name: "Fluent",
            dependencies: [
                .product(name: "FluentKit", package: "fluent-kit"),
                .product(name: "Vapor", package: "vapor"),
            ],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "FluentTests",
            dependencies: [
                .target(name: "Fluent"),
                .product(name: "XCTFluent", package: "fluent-kit"),
                .product(name: "XCTVapor", package: "vapor"),
            ],
            swiftSettings: swiftSettings
        ),
    ]
)

var swiftSettings: [SwiftSetting] { [
    .enableUpcomingFeature("ConciseMagicFile"),
    .enableUpcomingFeature("ForwardTrailingClosures"),
] }
