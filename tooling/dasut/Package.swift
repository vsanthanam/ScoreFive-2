// swift-tools-version:5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "dasut",
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.4.0"),
        .package(url: "https://github.com/vsanthanam/ShellOut", from: "2.3.0"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "4.0.3")
    ],
    targets: [
        .executableTarget(name: "dasut",
                          dependencies: [
                              .product(name: "ArgumentParser", package: "swift-argument-parser"),
                              .product(name: "ShellOut", package: "ShellOut"),
                              .product(name: "Yams", package: "Yams")
                          ]),
        .testTarget(
            name: "dasutTests",
            dependencies: ["dasut"]
        )
    ]
)
