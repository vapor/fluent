import PackageDescription

let package = Package(
    name: "Fluent",
    dependencies: [
        .Package(url: "https://github.com/IBM-Swift/LoggerAPI.git", versions: Version(0,3,0)..<Version(0,4,0)),
    ]
)