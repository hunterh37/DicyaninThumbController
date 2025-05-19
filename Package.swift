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
    dependencies: [],
    targets: [
        .target(
            name: "DicyaninThumbController",
            dependencies: []),
        .testTarget(
            name: "DicyaninThumbControllerTests",
            dependencies: ["DicyaninThumbController"]),
    ]
) 
