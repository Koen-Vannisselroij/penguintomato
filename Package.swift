// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "PenguinTomato",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "PenguinTomato", targets: ["PenguinTomato"])
    ],
    targets: [
        .executableTarget(
            name: "PenguinTomato",
            resources: [
                .process("Assets.xcassets"),
                .process("Resources")
            ]
        )
    ]
)
