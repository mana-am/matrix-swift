import SwiftUI

/// iOS-skeleton-style shimmer — a bright highlight sweeps top-left to bottom-right at a
/// fixed cadence. Per-cell phase = (row + col) / 8 (anti-diagonal slice norm).
struct DotmFunShimmer: View {
    var props = DotMatrixCommonProps(pattern: .full)
    var body: some View {
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
