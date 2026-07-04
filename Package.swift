// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Matrix",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v18),
    ],
    products: [
        .library(name: "Matrix", targets: ["Matrix"]),
    ],
    targets: [
        .target(
            name: "Matrix",
            resources: [
                .process("Resources/Localizable.xcstrings"),
            ]
        ),
        .testTarget(
            name: "MatrixTests",
            dependencies: ["Matrix"]
        ),
    ],
    // The Mana app builds in Swift 5 language mode (SWIFT_VERSION = 5.0); this
    // loader code was written against it. Match that so the package's strict-
    // concurrency posture equals the app's (e.g. the pool's static loader table).
    swiftLanguageModes: [.v5]
)
