import SwiftUI

/// iOS-skeleton-style shimmer — a bright highlight sweeps top-left to bottom-right at a
/// fixed cadence. Per-cell phase = (row + col) / 8 (anti-diagonal slice norm).
public struct DotmFunShimmer: View {
    var props = DotMatrixCommonProps(pattern: .full)
    init(props: DotMatrixCommonProps) { self.props = props }

    /// Source-parity ergonomic init — mirrors `<DotmFunShimmer size=… />` upstream. The
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
            if ctx.reducedMotion || ctx.phase == .idle {
                return baseOp + (peakOp - baseOp) * 0.5
            }
            let cycleSec = 1.4
            let t = DMKeyframes.phaseWithDelay(now: now, cycleSec: cycleSec, delaySec: 0)
            let cellPhase = Double(ctx.row + ctx.col) / 8.0
            return DMKeyframes.shimmer(t, cellPhase: cellPhase, base: baseOp, peak: peakOp)
        }
    }
}
