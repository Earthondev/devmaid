// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "DevMaid",
    platforms: [
        .macOS(.v13),
    ],
    products: [
        .library(
            name: "DevMaidKit",
            targets: ["DevMaidKit"]
        ),
        .executable(
            name: "devmaid",
            targets: ["DevMaidCLI"]
        ),
        .executable(
            name: "DevMaidApp",
            targets: ["DevMaidApp"]
        ),
    ],
    targets: [
        .target(
            name: "DevMaidKit"
        ),
        .executableTarget(
            name: "DevMaidCLI",
            dependencies: ["DevMaidKit"],
            path: "Sources/DevMaidCLI"
        ),
        .executableTarget(
            name: "DevMaidApp",
            dependencies: ["DevMaidKit"],
            path: "Sources/DevMaidApp",
            resources: [
                .process("Resources"),
            ],
            swiftSettings: [
                .unsafeFlags(["-parse-as-library"]),
            ]
        ),
        .testTarget(
            name: "DevMaidKitTests",
            dependencies: ["DevMaidKit"]
        ),
    ]
)
