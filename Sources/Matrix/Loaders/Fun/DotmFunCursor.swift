import SwiftUI

/// A bright "cursor" dot moves through the grid following a Lissajous curve, leaving a
/// short opacity tail behind it. Most "alive" of the loaders — the cursor never lands on
/// the same cell twice in a row.
public struct DotmFunCursor: View {
    var props = DotMatrixCommonProps(pattern: .full)
    init(props: DotMatrixCommonProps) { self.props = props }

    /// Source-parity ergonomic init — mirrors `<DotmFunCursor size=… />` upstream. The
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

    private static let CYCLE_SEC: Double = 3.5
    private static let TAIL_RADIUS: Double = 1.6  // cells

    public var body: some View {
        DotMatrixBase(props: props, bypassOpacityRemap: true) { ctx, now in
            let baseOp = props.opacityBase ?? DMKeyframes.DEFAULT_BASE
            let peakOp = props.opacityPeak ?? DMKeyframes.DEFAULT_PEAK
            // Lissajous parametric curve scanning a 5×5: x = 2 + 2*sin(a*φ), y = 2 + 2*sin(b*φ + δ).
            let phase = (now.truncatingRemainder(dividingBy: Self.CYCLE_SEC)) / Self.CYCLE_SEC
            let phi = 2 * .pi * phase
            let cx = 2.0 + 2.0 * sin(3 * phi)
            let cy = 2.0 + 2.0 * sin(2 * phi + .pi / 4)

            // Distance from this cell to the cursor.
            let dx = Double(ctx.col) - cx
            let dy = Double(ctx.row) - cy
            let dist = (dx * dx + dy * dy).squareRoot()

            if ctx.reducedMotion || ctx.phase == .idle {
                return 0.5 * (baseOp + peakOp)
            }

            if dist >= Self.TAIL_RADIUS { return baseOp }
            let u = 1 - dist / Self.TAIL_RADIUS
            let eased = u * u  // quadratic falloff
            return baseOp + (peakOp - baseOp) * eased
        }
    }
}
