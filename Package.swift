// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "UnityBuildKit",
    products: [
        .executable(name: "UnityBuildKit", targets: ["UnityBuildKit"]),
        .library(name: "UBKit", targets: ["UBKit"]),
        ],
    dependencies: [
        .package(url: "https://github.com/yonaskolb/XcodeGen.git", .upToNextMinor(from: "1.5.0"))
    ],
    targets: [
        .target(
            name: "UnityBuildKit",
            dependencies: ["UBKit"]),
        .target(
            name: "UBKit",
            dependencies: ["XcodeGenKit"]),
        ]
)

