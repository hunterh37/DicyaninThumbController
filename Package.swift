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
        .package(url: "https://github.com/hunterh37/DicyaninHandSessionManager.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "DicyaninThumbController",
            dependencies: ["DicyaninARKitSession"]),
        .testTarget(
            name: "DicyaninThumbControllerTests",
            dependencies: ["DicyaninThumbController"]),
    ]
) 