// swift-tools-version:5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "Serializable",
    platforms: [.macOS(.v10_13), .iOS(.v11), .tvOS(.v11), .watchOS(.v6)],
    products: [
        .library(
            name: "Serializable",
            targets: ["Serializable"]),
    ],
    targets: [
        .target(
            name: "Serializable",
            dependencies: []),
        .testTarget(
            name: "SerializableTests",
            dependencies: ["Serializable"]),
    ]
)
