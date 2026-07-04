import Matrix
import SwiftUI

/// A live showcase of every Matrix loader. Open `Example.swiftpm` in Swift
/// Playgrounds or Xcode and press Run: the gallery lets you browse all families
/// (Square / Circular / Hex / Fun / 3×3 / Triangle / Icon) and tune theme,
/// speed and color — plus a `Chat` tab that previews the drop-in
/// `MatrixLoadingView` at real chat scale.
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
