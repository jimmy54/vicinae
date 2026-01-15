// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Vicinae",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "Vicinae", targets: ["Vicinae"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-protobuf.git", from: "1.25.0"),
        // Add ZIPFoundation for later usage in Store
        .package(url: "https://github.com/weichsel/ZIPFoundation.git", .upToNextMajor(from: "0.9.0"))
    ],
    targets: [
        .executableTarget(
            name: "Vicinae",
            dependencies: [
                .product(name: "SwiftProtobuf", package: "swift-protobuf"),
                .product(name: "ZIPFoundation", package: "ZIPFoundation")
            ],
            path: "Sources",
            resources: [
                .copy("Resources")
            ]
        )
    ]
)
