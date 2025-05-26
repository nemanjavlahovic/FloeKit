// swift-tools-version: 5.9
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
            targets: ["FloeKit"]),
            description: "Elegant, modular UI building blocks for SwiftUI with theming, typography, and spacing."
    ],
    dependencies: [],
    targets: [
        .target(
            name: "FloeKit",
            dependencies: [],
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "FloeKitTests",
            dependencies: ["FloeKit"]),
    ]
) 