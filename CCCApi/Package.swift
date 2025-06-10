// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CCCApi",
    platforms: [.tvOS(.v17), .iOS(.v17), .macOS(.v14)],
    products: [
        .library(
            name: "CCCApi",
            targets: ["CCCApi"]
        )
    ],
    targets: [
        .target(
            name: "CCCApi"
        )
    ]
)
