import PackageDescription

let package = Package(
    name: "Fluent",
    dependencies: [ 
        .Package(url: "https://github.com/qutheory/libc.git", majorVersion: 0, minor: 1),
    ]
)