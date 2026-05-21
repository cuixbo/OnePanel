// swift-tools-version: 6.3

import PackageDescription

let package = Package(
    name: "OnePanel",
    platforms: [
        .macOS(.v14)
    ],
    targets: [
        .executableTarget(
            name: "OnePanel"
        ),
        .testTarget(
            name: "OnePanelTests",
            dependencies: ["OnePanel"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
