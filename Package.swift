import PackageDescription

let package = Package(
    name: "Fluent",
    dependencies: [
        .Package(url: "https://github.com/qutheory/csqlite.git", majorVersion: 0, minor: 1),
        .Package(url: "https://github.com/PlanTeam/MongoKitten.git", majorVersion: 0, minor: 9)
    ],
    targets: [
        Target(
            name: "Fluent",
            dependencies: [
                .Target(name: "libc")
            ]
        ),
        Target(
            name: "FluentSQLite",
            dependencies: [
                .Target(name: "Fluent")
            ]
        ),
        Target(
            name: "FluentMongo",
            dependencies: [
                .Target(name: "Fluent")
            ]
        ),
        Target(
            name: "FluentDev",
            dependencies: [
                .Target(name: "Fluent"),
                .Target(name: "FluentSQLite"),
                .Target(name: "FluentMongo"),
            ]
        ),
    ]
)