// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RemoteCameraCore",
    platforms: [
        .macOS(.v15),
        .iOS(.v17),
        .watchOS(.v8),
        .tvOS(.v15),
        .visionOS(.v2),
    ],
    products: [
        .library(
            name: "RemoteCameraCore",
            targets: ["RemoteCameraCore"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/yu840915/AsyncUtils.git",
            branch: "main",
        ),
        .package(
            url: "https://github.com/apple/swift-log",
            from: "1.6.0",
        ),
    ],
    targets: [
        .target(
            name: "RemoteCameraCore",
            dependencies: [
                "AsyncUtils"
            ]
        ),
        .testTarget(
            name: "RemoteCameraCoreTests",
            dependencies: [
                "RemoteCameraCore",
                "AsyncUtils",
            ]
        ),
    ]
)
