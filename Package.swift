// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RemoteCameraCore",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
        .watchOS(.v8),
        .tvOS(.v15),
        .visionOS(.v2),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "RemoteCameraCore",
            targets: ["RemoteCameraCore"])
    ],
    dependencies: [
        .package(name: "CameraCore", path: "file:///Users/lixuanyu/swift_proj.nosync/CameraControl")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "RemoteCameraCore",
            dependencies: [
                "CameraCore"
            ]
        ),
        .testTarget(
            name: "RemoteCameraCoreTests",
            dependencies: ["RemoteCameraCore"]
        ),
    ]
)
