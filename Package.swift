import PackageDescription

let package = Package(
    name: "Fluent",
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