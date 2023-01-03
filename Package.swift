// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "StringTemplate",
    platforms: [
        .iOS(.v11),
        .macOS(.v10_13),
        .tvOS(.v11),
        .watchOS(.v4),
    ],
    products: [
        .library(
            name: "StringTemplate",
            targets: ["StringTemplate"]
        ),
    ],
    targets: [
        .target(
            name: "StringTemplate",
            dependencies: [],
            path: "Sources"
        ),
        .testTarget(
            name: "StringTemplateTests",
            dependencies: ["StringTemplate"],
            path: "Tests"
        ),
    ]
)
