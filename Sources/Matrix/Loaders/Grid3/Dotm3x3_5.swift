import SwiftUI

/// 3×3 diagonal wave, bottom-left → top-right. Mirrors `dotm-3x3-5.tsx`.
public struct Dotm3x3_5: View {
    var props = DotMatrixCommonProps(speed: 1.15, pattern: .full)
    init(props: DotMatrixCommonProps) { self.props = props }

    /// Source-parity ergonomic init — mirrors `<Dotm3x3_5 size=… />` upstream. The
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

    public var body: some View {
        DiagonalWave3Loader(props: props, direction: .blTr)
    }
}
