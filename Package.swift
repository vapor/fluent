import PackageDescription

let package = Package(
    name: "Fluent",
    dependencies: [
        //Standards package. Contains protocols for cross-project compatability.
        .Package(url: "https://github.com/open-swift/C7.git", majorVersion: 0, minor: 8)
    ]
)
