import SwiftUI

/// 3×3 glyph spin — L-shaped corner glyph rotated in 90° steps. Mirrors `dotm-3x3-20.tsx`.
struct Dotm3x3_20: View {
    var props = DotMatrixCommonProps(speed: 1, pattern: .full)
    /// L-shaped corner — row-major 0/1 form.
    private static let glyph = [1, 1, 0, 1, 0, 0, 1, 0, 0]
    var body: some View {
        GlyphSpin3Loader(props: props, glyph: Self.glyph)
    }
}
