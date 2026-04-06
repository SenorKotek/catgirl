// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "app",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "app", targets: ["app"])
    ],
    targets: [
        .executableTarget(
            name: "app",
            path: "Sources"
        )
    ]
)
