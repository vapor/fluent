import PackageDescription
#if os(Linux)
    import Glibc
#else
    import Darwin.C
#endif

public enum Env {
    public static func get(_ name: String) -> String? {
        guard let out = getenv(name) else { return nil }
        return String(validatingUTF8: out)
    }
}

var dependencies: [Package.Dependency] = [
    // Data structure for converting between multiple representations
    .Package(url: "https://github.com/vapor/node.git", majorVersion: 2),

    // Core Components
    .Package(url: "https://github.com/vapor/core.git", majorVersion: 2),

    // Random number generation
    .Package(url: "https://github.com/vapor/random.git", majorVersion: 1),
]

let includeSQLite = Env.get("FLUENT_NO_SQLITE")?.lowercased() != "true"
if includeSQLite {
    dependencies += [
        // In memory Database
        .Package(url: "https://github.com/vapor/sqlite.git", majorVersion: 2)
    ]
}

let package = Package(
    name: "Fluent",
    targets: [
        Target(name: "Fluent"),
        Target(name: "FluentTester", dependencies: ["Fluent"]),
    ],
    dependencies: dependencies
)
