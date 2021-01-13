// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SemanticsInfra",
    platforms: [.iOS(.v14)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "SemanticsInfra",
            targets: ["SemanticsInfra"]),
        .library(
            name: "SemNetworking",
            targets: ["SemNetworking"]),
        .library(
            name: "SemGeometry",
            targets: ["SemGeometry"]),
        .library(
            name: "SemLog",
            targets: ["SemLog"]),
        .library(
            name: "SemDS",
            targets: ["SemDS"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(name:"Metron", url: "https://github.com/toineheuvelmans/metron.git", from: "1.0.4"),
        .package(name: "Sentry", url: "https://github.com/getsentry/sentry-cocoa", from: "6.0.12"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "SemanticsInfra"),
        .target(
            name: "SemLog",
            dependencies: ["Sentry"]),
        .target(
            name: "SemNetworking"),
        .target(
            name: "SemGeometry",
            dependencies: ["Metron"]),
        .target(
            name: "SemDS"),
        
        .testTarget(
            name: "SemanticsInfraTests",
            dependencies: ["SemanticsInfra"]),
        .testTarget(
            name: "SemGeometryTests",
            dependencies: ["SemGeometry"])
    ]
)
