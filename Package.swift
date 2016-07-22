import PackageDescription

let package = Package(
    name: "Fluent",
    dependencies: [
        // Syntax for easily accessing values from generic data.
        .Package(url: "https://github.com/qutheory/polymorphic.git", majorVersion: 0, minor: 3),

        // Syntax for easily indexing arrays and dictionaries.
        .Package(url: "https://github.com/qutheory/path-indexable.git", majorVersion: 0, minor: 3),

		// Data structure for converting between multiple representations
		.Package(url: "https://github.com/qutheory/node.git", majorVersion: 0, minor: 2)
    ]
)
