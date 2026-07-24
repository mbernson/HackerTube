// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MediaCCCApi",
    defaultLocalization: "de",
    products: [
        .library(
            name: "MediaCCCApi",
            targets: ["MediaCCCApi"]
        )
    ],
    targets: [
        .target(
            name: "MediaCCCApi",
            resources: [
                .process("Resources/Localizable.xcstrings")
            ]
        ),
        .testTarget(
            name: "MediaCCCApiTests",
            dependencies: ["MediaCCCApi"]
        )
    ]
)
