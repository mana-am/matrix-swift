import SwiftUI

/// All cells inhale/exhale together on a 4-second sine cycle. Calmest of the loaders.
struct DotmFunBreathing: View {
    var props = DotMatrixCommonProps(pattern: .full)
    var body: some View {
        DotMatrixBase(props: props, bypassOpacityRemap: true) { ctx, now in
            let baseOp = props.opacityBase ?? DMKeyframes.DEFAULT_BASE
            let peakOp = props.opacityPeak ?? DMKeyframes.DEFAULT_PEAK
            if ctx.reducedMotion || ctx.phase == .idle {
                return 0.5 * (baseOp + peakOp)
            }
            let cycleSec = 4.0
            let t = DMKeyframes.phaseWithDelay(now: now, cycleSec: cycleSec, delaySec: 0)
            return DMKeyframes.breathing(t, base: baseOp, peak: peakOp)
        }
    }
}
