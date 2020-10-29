// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "Serializable",
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
    ],
    swiftLanguageVersions: [.v5]
)
