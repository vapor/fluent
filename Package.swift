import PackageDescription

let beta2 = Version(2,0,0, prereleaseIdentifiers: ["beta"])
let beta1 = Version(1,0,0, prereleaseIdentifiers: ["beta"])
let package = Package(
    name: "Fluent",
    targets: [
        Target(name: "Fluent"),
        Target(name: "FluentTester", dependencies: ["Fluent"]),
    ],
    dependencies: [
        // Data structure for converting between multiple representations
        .Package(url: "https://github.com/vapor/node.git", beta2),

        // Core Components
        .Package(url: "https://github.com/vapor/core.git", beta2),
        
        // Random number generation
        .Package(url: "https://github.com/vapor/random", beta1),

        // In memory Database
        .Package(url: "https://github.com/vapor/sqlite.git", beta2)
    ]
)
