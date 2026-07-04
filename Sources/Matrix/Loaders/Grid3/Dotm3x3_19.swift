import SwiftUI

/// 3×3 glyph spin — right-arrow glyph rotated in 90° steps. Mirrors `dotm-3x3-19.tsx`.
public struct Dotm3x3_19: View {
    var props = DotMatrixCommonProps(speed: 1, pattern: .full)
    init(props: DotMatrixCommonProps) { self.props = props }

    /// Source-parity ergonomic init — mirrors `<Dotm3x3_19 size=… />` upstream. The
    /// loader's shape/pattern is fixed; you size and color it.
    public init(
        size: CGFloat = 24,
        color: Color = .primary,
        speed: Double = 1,
        dotSize: CGFloat? = nil,
        muted: Bool = false,
        bloom: Bool = false,
        halo: Double = 0
    ) {
        props.size = size
        props.color = color
        props.speed = speed
        props.dotSize = dotSize ?? max(2, floor(size / 6))
        props.muted = muted
        props.bloom = bloom
        props.halo = halo
    }

    /// Right arrow — row-major 0/1 form.
    private static let glyph = [0, 1, 0, 0, 1, 1, 0, 1, 0]
    public var body: some View {
        GlyphSpin3Loader(props: props, glyph: Self.glyph)
    }
}
