import PackageDescription

let package = Package(
    name: "Fluent",
    dependencies: [
        //Standards package. Contains protocols for cross-project compatability.
        .Package(url: "https://github.com/open-swift/C7.git", majorVersion: 0, minor: 9),

        // Syntax for easily accessing values from generic data.
        .Package(url: "https://github.com/qutheory/polymorphic.git", majorVersion: 0, minor: 2),

        // Syntax for easily indexing arrays and dictionaries.
        .Package(url: "https://github.com/qutheory/path-indexable.git", majorVersion: 0, minor: 2)
    ]
)
