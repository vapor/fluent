// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "fluent",
    platforms: [
       .macOS(.v10_15),
    ],
    products: [
        .library(name: "Fluent", targets: ["Fluent"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/fluent-kit.git", from: "1.0.0-rc.1.19"),
        .package(url: "https://github.com/tdotclare/vapor.git", .revision("dd96adce562c5a9ff2c9c1805f345b291acf25f8")),
    ],
    targets: [
        .target(name: "Fluent", dependencies: [
            .product(name: "FluentKit", package: "fluent-kit"),
            .product(name: "Vapor", package: "vapor"),
        ]),
        .testTarget(name: "FluentTests", dependencies: [
            .target(name: "Fluent"),
            .product(name: "XCTFluent", package: "fluent-kit"),
            .product(name: "XCTVapor", package: "vapor"),
        ]),
    ]
)
