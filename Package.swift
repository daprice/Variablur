// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Variablur",
	platforms: [
		.macOS(.v14), .iOS(.v17), .tvOS(.v17), .macCatalyst(.v17), .visionOS(.v1)
	],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Variablur",
            targets: ["Variablur"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Variablur",
			resources: [.process("Blurs.metal")]
		),
        .testTarget(
            name: "VariablurTests",
            dependencies: ["Variablur"]),
    ]
)
