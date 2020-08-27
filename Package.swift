// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SimpleNetwork",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "SimpleNetwork",
            targets: ["SimpleNetwork"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "5.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "SimpleNetwork",
            dependencies: [
//            .product(name: "SwiftyJSON", package: "swiftyJSON"),
            .product(name: "SwiftyJSON", package: "SwiftyJSON"),
        ]),
        .testTarget(
            name: "SimpleNetworkTests",
            dependencies: ["SimpleNetwork"]),
    ]
)
