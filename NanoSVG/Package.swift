// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NanoSVG",
    products: [
        .library(
            name: "NanoSVG",
            targets: ["NanoSVG"]
        ),
    ],
    targets: [
        .target(
            name: "NanoSVG",
            dependencies: ["CNanoSVG"]
        ),
        .target(name: "CNanoSVG"),

        .testTarget(
            name: "NanoSVGTests",
            dependencies: ["NanoSVG"],
            resources: [.copy("TestData")]
        ),
    ]
)
