import SwiftUI

/// 3×3 glyph spin — checkmark glyph rotated in 90° steps. Mirrors `dotm-3x3-18.tsx`.
struct Dotm3x3_18: View {
    var props = DotMatrixCommonProps(speed: 1, pattern: .full)
    /// Checkmark — row-major 0/1 form.
    private static let glyph = [0, 0, 1, 0, 1, 0, 1, 0, 0]
    var body: some View {
        GlyphSpin3Loader(props: props, glyph: Self.glyph)
    }
}
