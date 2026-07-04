import SwiftUI

/// Sine-wave silhouette — each cell brightens with a delay proportional to col, so the
/// wave appears to travel left-to-right.
struct DotmFunWaveShape: View {
    var props = DotMatrixCommonProps(pattern: .wave)
    var body: some View {
        DotMatrixBase(props: props, bypassOpacityRemap: true) { ctx, now in
            let baseOp = props.opacityBase ?? DMKeyframes.DEFAULT_BASE
            let midOp = props.opacityMid ?? DMKeyframes.DEFAULT_MID
            let peakOp = props.opacityPeak ?? DMKeyframes.DEFAULT_PEAK
            let norm = Double(ctx.col) / 4.0
            if ctx.reducedMotion || ctx.phase == .idle {
                return midOp
            }
            let cycleSec = 1.4
            let delay = norm * 0.6 * cycleSec
            let t = DMKeyframes.phaseWithDelay(now: now, cycleSec: cycleSec, delaySec: delay)
            return DMKeyframes.rippleEcho(t, base: baseOp, mid: midOp, peak: peakOp)
        }
    }
}
