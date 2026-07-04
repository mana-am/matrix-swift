import SwiftUI

/// 3×3 glyph spin — smiley glyph rotated in 90° steps. Mirrors `dotm-3x3-16.tsx`.
struct Dotm3x3_16: View {
    var props = DotMatrixCommonProps(speed: 1, pattern: .full)
    /// Smiley — eyes and mouth in row-major 0/1 form.
    private static let glyph = [1, 0, 1, 0, 0, 0, 0, 1, 0]
    var body: some View {
        GlyphSpin3Loader(props: props, glyph: Self.glyph)
    }
}
