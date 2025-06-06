// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "FloeKit",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "FloeKit",
            targets: ["FloeKit"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "FloeKit",
            dependencies: [],
            resources: [
                .process("Resources")
            ]
        )
    ]
)