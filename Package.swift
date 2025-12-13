// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FHKStorage",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "FHKStorage",
            targets: ["FHKStorage"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/leonodev/fintechKids-modulo-utils-ios.git",
            .upToNextMajor(from: "1.0.2")),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "FHKStorage",
            dependencies: [
                // Modules
                .product(name: "FHKUtils", package: "fintechKids-modulo-utils-ios")
            ]
        ),
        .testTarget(
            name: "FHKStorageTests",
            dependencies: ["FHKStorage"]
        ),
    ]
)
