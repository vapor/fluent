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
            name: "FluentDev",
            dependencies: [
                .Target(name: "Fluent"),
            ]
        ),
    ]
)