// swift-tools-version:5.3

import PackageDescription


let package = Package(
    name: "LastMile",
    products: [.library(name: "LastMile", targets: ["LastMile"])],
    dependencies: [],
    targets: [
        .target(name: "LastMile", dependencies: []),
        .testTarget(name: "LastMileTests", dependencies: ["LastMile"]),
        .testTarget(name: "LastMilePerformanceTests", dependencies: ["LastMile"])
    ]
)
