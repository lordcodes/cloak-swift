// swift-tools-version: 5.5

import PackageDescription

let package = Package(
    name: "cloak",
    platforms: [.macOS(.v11)],
    products: [
        .executable(
            name: "tuist-cloak",
            targets: ["CloakCLI"]
        ),
        .executable(
            name: "cloakswift",
            targets: ["CloakCLI"]
        ),
        .library(name: "CloakKit", targets: ["CloakKit"])
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "CloakCLI",
            dependencies: ["CloakKit"]
        ),
        .target(
            name: "CloakKit",
            dependencies: []
        ),
        .testTarget(
            name: "CloakKitTests",
            dependencies: ["CloakKit"]
        ),
    ]
)
