// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "sftool",
    products: [
        .executable(name: "sftool", targets: ["sftool"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.3.1"),
        .package(url: "https://github.com/vsanthanam/ShellOut", from: "2.3.0"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "4.0.3")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "sftool",
            dependencies: [.product(name: "ArgumentParser", package: "swift-argument-parser"),
                           .product(name: "ShellOut", package: "ShellOut"),
                           .product(name: "Yams", package: "Yams")]
        ),
        .testTarget(
            name: "sftoolTests",
            dependencies: ["sftool"]
        )
    ]
)
