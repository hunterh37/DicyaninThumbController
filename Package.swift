// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "DicyaninThumbController",
    platforms: [
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "DicyaninThumbController",
            targets: ["DicyaninThumbController"]),
    ],
    dependencies: [
        .package(path: "DicyaninARKitSession")
    ],
    targets: [
        .target(
            name: "DicyaninHandTracking",
            dependencies: ["DicyaninARKitSession"]),
        .testTarget(
            name: "DicyaninThumbControllerTests",
            dependencies: ["DicyaninThumbController"]),
    ]
) 
