// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "parrot",
    products: [
        .library(
            name: "parrot",
            targets: ["parrot"]
        )
    ],
    targets: [
        .target(
            name: "parrot",
            dependencies: []
        )
    ]
)
