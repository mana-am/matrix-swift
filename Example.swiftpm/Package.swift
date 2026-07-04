// swift-tools-version: 6.0

// A Swift Playgrounds app. Open `Example.swiftpm` in Swift Playgrounds or Xcode
// and press Run to experience every loader live on device or simulator.

import AppleProductTypes
import PackageDescription

let package = Package(
    name: "Example",
    platforms: [
        .iOS("18.0")
    ],
    products: [
        .iOSApplication(
            name: "Example",
            targets: ["AppModule"],
            bundleIdentifier: "am.mana.Matrix.Example",
            displayVersion: "1.0",
            bundleVersion: "1",
            supportedDeviceFamilies: [
                .pad,
                .phone,
            ],
            supportedInterfaceOrientations: [
                .portrait,
                .landscapeRight,
                .landscapeLeft,
                .portraitUpsideDown(.when(deviceFamilies: [.pad])),
            ]
        )
    ],
    dependencies: [
        .package(path: "..")
    ],
    targets: [
        .executableTarget(
            name: "AppModule",
            dependencies: [
                .product(name: "Matrix", package: "matrix-swift")
            ],
            path: "."
        )
    ]
)
