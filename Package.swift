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
            targets: ["DicyaninHandTracking"]),
    ],
    dependencies: [
        .package(url: "https://github.com/hunterh37/DicyaninARKitSession.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "DicyaninHandTracking",
            dependencies: ["DicyaninARKitSession"]),
        .testTarget(
            name: "DicyaninThumbControllerTests",
            dependencies: ["DicyaninHandTracking"]),
    ]
) 
