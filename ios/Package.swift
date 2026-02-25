// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "AviatorDemo",
    targets: [
        .target(
            name: "AviatorDemo",
            path: "Sources/AviatorDemo"
        ),
        .testTarget(
            name: "AviatorDemoTests",
            dependencies: ["AviatorDemo"],
            path: "Tests/AviatorDemoTests"
        ),
    ]
)
