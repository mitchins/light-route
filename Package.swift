// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "LightRoute",
    platforms: [
        .iOS(.v18),
        .macOS(.v15),
        .tvOS(.v18),
        .watchOS(.v11)
    ],
    products: [
        .library(
            name: "LightRoute",
            targets: ["LightRoute"]
        ),
        .library(
            name: "LightRouteTesting",
            targets: ["LightRouteTesting"]
        )
    ],
    targets: [
        .target(
            name: "LightRoute"
        ),
        .target(
            name: "LightRouteTesting",
            dependencies: ["LightRoute"]
        ),
        .testTarget(
            name: "LightRouteTests",
            dependencies: ["LightRoute"]
        ),
        .testTarget(
            name: "LightRouteTestingTests",
            dependencies: [
                "LightRoute",
                "LightRouteTesting"
            ]
        )
    ],
    swiftLanguageModes: [.v6]
)