// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "Serializable",
    products: [.library(name: "Serializable", targets: ["Serializable"])],
    targets: [
        .target(name: "Serializable"),
        .testTarget(name: "SerializableTests", dependencies: ["Serializable"])
    ],
    swiftLanguageVersions: [4, 5]
)
