import PackageDescription

let package = Package(
    name: "Fluent",
    targets: [
        Target(name: "Fluent"),
        Target(name: "FluentTester", dependencies: ["Fluent"]),
    ],
    dependencies: [
        // Data structure for converting between multiple representations
        .Package(url: "https://github.com/vapor/node.git", Version(2,0,0, prereleaseIdentifiers: ["alpha"])),

        // Core Components
        .Package(url: "https://github.com/vapor/core.git", Version(2,0,0, prereleaseIdentifiers: ["alpha"])),

        // In memory Database
        .Package(url: "https://github.com/vapor/sqlite.git", Version(2,0,0, prereleaseIdentifiers: ["alpha"])),
    ]
)
