// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Gwen",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "Gwen", targets: ["Gwen"])
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "Gwen",
            dependencies: [],
            path: "Sources/Gwen",
            swiftSettings: []
        ),
        .testTarget(
            name: "GwenTests",
            dependencies: ["Gwen"],
            path: "Tests/GwenTests"
        )
    ]
)
