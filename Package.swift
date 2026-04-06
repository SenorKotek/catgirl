// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CatgirlDockApp",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "CatgirlDockApp", targets: ["CatgirlDockApp"])
    ],
    targets: [
        .executableTarget(
            name: "CatgirlDockApp",
            path: "Sources"
        )
    ]
)
