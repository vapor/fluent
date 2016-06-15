import PackageDescription

let package = Package(
    name: "Fluent",
    dependencies: [
        //Standards package. Contains protocols for cross-project compatability.
        .Package(url: "https://github.com/open-swift/C7.git", majorVersion: 0, minor: 9),

        // Syntax for easily accessing values from generic data.
        .Package(url: "https://github.com/qutheory/polymorphic.git", majorVersion: 0, minor: 2),

        .Package(url: "https://github.com/qutheory/cmysql.git", majorVersion: 0, minor: 1),

        .Package(url: "https://github.com/qutheory/csqlite.git", majorVersion: 0, minor: 1),

        .Package(url: "https://github.com/qutheory/libc.git", majorVersion: 0, minor: 1),
    ],
    targets: [
        Target(
            name: "FluentMySQL",
            dependencies: [
                .Target(name: "MySQL"),
                .Target(name: "Fluent")
            ]
        ),
        Target(
            name: "MySQL"
        ),

        Target(
            name: "FluentSQLite",
            dependencies: [
                .Target(name: "SQLite"),
                .Target(name: "Fluent")
            ]
        ),
        Target(
            name: "SQLite"
        ),

        Target(
            name: "Fluent"
        ),
    ]
)
