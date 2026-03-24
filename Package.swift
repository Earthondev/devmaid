// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "DevMaid",
    platforms: [
        .macOS(.v13),
    ],
    products: [
        .library(
            name: "RoomServiceKit",
            targets: ["RoomServiceKit"]
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
            name: "RoomServiceKit"
        ),
        .executableTarget(
            name: "DevMaidCLI",
            dependencies: ["RoomServiceKit"],
            path: "Sources/RoomServiceCLI"
        ),
        .executableTarget(
            name: "DevMaidApp",
            dependencies: ["RoomServiceKit"],
            path: "Sources/RoomServiceApp",
            resources: [
                .process("Resources"),
            ],
            swiftSettings: [
                .unsafeFlags(["-parse-as-library"]),
            ]
        ),
    ]
)
