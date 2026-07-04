import Matrix
import SwiftUI

/// A live showcase of every Matrix loader. Open `Example.swiftpm` in Swift
/// Playgrounds or Xcode and press Run: the gallery lets you browse all families
/// (Square / Circular / Hex / Fun / 3×3 / Triangle / Icon) via the Liquid-Glass
/// chip bar, and tune theme, speed and color.
@main
struct ExampleApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                MatrixLoaderGallery()
            }
        }
    }
}
