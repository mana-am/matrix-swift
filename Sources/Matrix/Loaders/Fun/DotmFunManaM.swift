import SwiftUI

/// Mana brand "M" letter — diagonal-alt-sweep brushes through the silhouette so the M
/// shimmers from top-left to bottom-right.
public struct DotmFunManaM: View {
    var props = DotMatrixCommonProps(pattern: .manaM)
    init(props: DotMatrixCommonProps) { self.props = props }

    /// Source-parity ergonomic init — mirrors `<DotmFunManaM size=… />` upstream. The
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
        DotMatrixBase(props: props, bypassOpacityRemap: true) { ctx, now in
            let baseOp = props.opacityBase ?? DMKeyframes.DEFAULT_BASE
            let peakOp = props.opacityPeak ?? DMKeyframes.DEFAULT_PEAK
            // Anti-diagonal slice index (0…8 across the 5×5).
            let slice = ctx.row + ctx.col
            let norm = Double(slice) / 8.0
            if ctx.reducedMotion || ctx.phase == .idle {
                return baseOp + norm * (peakOp - baseOp)
            }
            let cycleSec = 1.6
            let delay = norm * 0.55 * cycleSec
            let t = DMKeyframes.phaseWithDelay(now: now, cycleSec: cycleSec, delaySec: delay)
            return DMKeyframes.diagonalAltSweep(t, base: baseOp, peak: peakOp)
        }
    }
}
