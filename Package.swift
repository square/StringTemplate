// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "StringTemplate",
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
