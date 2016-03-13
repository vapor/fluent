import PackageDescription

let package = Package(
    name: "Fluent",
    dependencies: [
                   
    ],
    exclude: [],
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
          .Target(name: "Fluent")
        ]
        )
    ]
)

//with the new swiftpm we have to force it to create a static lib so that we can use it
//from xcode. this will become unnecessary once official xcode+swiftpm support is done.
//watch progress: https://github.com/apple/swift-package-manager/compare/xcodeproj?expand=1

let lib = Product(name: "Fluent", type: .Library(.Dynamic), modules: "Fluent")
products.append(lib)