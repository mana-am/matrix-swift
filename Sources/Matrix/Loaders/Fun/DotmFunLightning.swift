import SwiftUI

/// Lightning bolt ⚡ — a flash sweeps top-to-bottom along the bolt path. Uses the
/// shimmer keyframe with cellPhase = row/4.
struct DotmFunLightning: View {
    var props = DotMatrixCommonProps(pattern: .lightning)
    var body: some View {
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
