import SwiftUI

/// A drop of ink hits cell (2,2) and bleeds outward. Per-cell delay is proportional to
/// Manhattan distance from center, so the ink "spreads" radially. Uses an asymmetric
/// ease-out keyframe so the saturation rises fast and fades slowly, like real ink on paper.
struct DotmFunInkBleed: View {
    var props = DotMatrixCommonProps(pattern: .full)
    var body: some View {
        DotMatrixBase(props: props, bypassOpacityRemap: true) { ctx, now in
            let baseOp = props.opacityBase ?? DMKeyframes.DEFAULT_BASE
            let midOp = props.opacityMid ?? DMKeyframes.DEFAULT_MID
            let peakOp = props.opacityPeak ?? DMKeyframes.DEFAULT_PEAK
            // Distance from grid center (2,2) — Manhattan range is 0…4 on a 5×5.
            let manhattan = ctx.manhattanDistance
            let norm = Double(manhattan) / 4.0
            if ctx.reducedMotion || ctx.phase == .idle {
                return midOp - norm * (midOp - baseOp) * 0.6
            }
            let cycleSec = 1.8
            let delay = Double(manhattan) * 0.16 * cycleSec
            let t = DMKeyframes.phaseWithDelay(now: now, cycleSec: cycleSec, delaySec: delay)
            return DMKeyframes.inkBleed(t, base: baseOp, mid: midOp, peak: peakOp)
        }
    }
}
