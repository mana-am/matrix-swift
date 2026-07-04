import SwiftUI

/// 3×3 glyph spin — play-triangle glyph rotated in 90° steps. Mirrors `dotm-3x3-21.tsx`.
struct Dotm3x3_21: View {
    var props = DotMatrixCommonProps(speed: 1, pattern: .full)
    /// Play triangle — row-major 0/1 form.
    private static let glyph = [1, 0, 0, 1, 1, 0, 1, 0, 0]
    var body: some View {
        GlyphSpin3Loader(props: props, glyph: Self.glyph)
    }
}
