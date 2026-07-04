import SwiftUI

/// Sparkle ✦ — center cross flashes first, then the four corner stars fire after a small
/// delay. Uses the confetti-pop keyframe per cell.
struct DotmFunSparkle: View {
    var props = DotMatrixCommonProps(pattern: .sparkle)
    var body: some View {
        DotMatrixBase(props: props, bypassOpacityRemap: true) { ctx, now in
            let baseOp = props.opacityBase ?? DMKeyframes.DEFAULT_BASE
            let midOp = props.opacityMid ?? DMKeyframes.DEFAULT_MID
            let peakOp = props.opacityPeak ?? DMKeyframes.DEFAULT_PEAK
            // Corners fire after the cross.
            let isCorner =
                (ctx.row == 0 || ctx.row == 4) && (ctx.col == 0 || ctx.col == 2 || ctx.col == 4)
                && !(ctx.col == 2)
            if ctx.reducedMotion || ctx.phase == .idle {
                return midOp
            }
            let cycleSec = 1.4
            let delay = isCorner ? 0.18 * cycleSec : 0
            let t = DMKeyframes.phaseWithDelay(now: now, cycleSec: cycleSec, delaySec: delay)
            return DMKeyframes.confettiPop(t, base: baseOp, mid: midOp, peak: peakOp)
        }
    }
}
