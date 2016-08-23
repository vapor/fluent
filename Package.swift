import PackageDescription

let package = Package(
    name: "Fluent",
    dependencies: [
        // Data structure for converting between multiple representations
        .Package(url: "https://github.com/vapor/node.git", majorVersion: 0, minor: 5)
    ]
)
