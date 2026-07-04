import SwiftUI

/// 3×3 glyph spin — right-arrow glyph rotated in 90° steps. Mirrors `dotm-3x3-19.tsx`.
struct Dotm3x3_19: View {
    var props = DotMatrixCommonProps(speed: 1, pattern: .full)
    /// Right arrow — row-major 0/1 form.
    private static let glyph = [0, 1, 0, 0, 1, 1, 0, 1, 0]
    var body: some View {
        GlyphSpin3Loader(props: props, glyph: Self.glyph)
    }
}
