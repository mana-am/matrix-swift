import SwiftUI

/// Lightning bolt ⚡ — a flash sweeps top-to-bottom along the bolt path. Uses the
/// shimmer keyframe with cellPhase = row/4.
public struct DotmFunLightning: View {
    var props = DotMatrixCommonProps(pattern: .lightning)
    init(props: DotMatrixCommonProps) { self.props = props }

    /// Source-parity ergonomic init — mirrors `<DotmFunLightning size=… />` upstream. The
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
                return baseOp + (peakOp - baseOp) * 0.7
            }
            let cycleSec = 1.0
            let t = DMKeyframes.phaseWithDelay(now: now, cycleSec: cycleSec, delaySec: 0)
            let cellPhase = Double(ctx.row) / 4.0
            return DMKeyframes.shimmer(t, cellPhase: cellPhase, base: baseOp, peak: peakOp)
        }
    }
}
