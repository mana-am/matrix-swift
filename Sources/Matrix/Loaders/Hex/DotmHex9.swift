import SwiftUI

/// Petal Shimmer — 2 main petals + 2 cross petals rotate around the center,
/// outer ring shimmers based on radius. Mirrors upstream `dotm-hex-9.tsx`.
public struct DotmHex9: View {
    var props = DotMatrixCommonProps(speed: 1.8, pattern: .full)
    init(props: DotMatrixCommonProps) { self.props = props }

    /// Source-parity ergonomic init — mirrors `<DotmHex9 size=… />` upstream. The
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


    private static let petalWidth: Double = 0.42
    private static let baseOp: Double = 0.15
    private static let highOp: Double = 0.98

    public var body: some View {
        DotMatrixHexBase(props: props, timing: .cycle(cycleMsBase: 1650)) { row, col, phase in
            let polar = HexCell.polar(row: row, col: col)
            if polar.radius < 0.1 {
                return 0.42 + sin(phase * .pi * 2) * 0.2
            }
            let rotation = phase * .pi * 2
            let petalA = max(
                0, 1 - dmHexAngularDistanceUnsigned(polar.angle, rotation) / Self.petalWidth
            )
            let petalB = max(
                0, 1 - dmHexAngularDistanceUnsigned(polar.angle, rotation + .pi) / Self.petalWidth
            )
            let crossA = max(
                0, 1 - dmHexAngularDistanceUnsigned(polar.angle, rotation + .pi / 2) / 0.52
            ) * 0.46
            let crossB = max(
                0, 1 - dmHexAngularDistanceUnsigned(polar.angle, rotation + .pi * 1.5) / 0.52
            ) * 0.46
            let ring = (0.5 + 0.5 * sin(phase * .pi * 2 - polar.radius * 2.7))
                * (polar.radius > 1.3 ? 0.22 : 0.1)
            let petalPeak = max(petalA, petalB)
            if petalPeak > 0.92 { return Self.highOp }
            return min(Self.highOp, Self.baseOp + petalPeak * 0.82 + crossA + crossB + ring)
        }
    }
}
