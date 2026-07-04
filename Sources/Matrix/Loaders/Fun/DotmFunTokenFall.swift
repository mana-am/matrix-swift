import SwiftUI

/// "Tokens" cascade into cells from top-left to bottom-right, like an answer being typed
/// out. Per-cell delay = row × dt + col × dt/2, so each row settles a beat after the
/// previous, with intra-row left-to-right stagger.
struct DotmFunTokenFall: View {
    var props = DotMatrixCommonProps(pattern: .full)
    var body: some View {
        DotMatrixBase(props: props, bypassOpacityRemap: true) { ctx, now in
            let baseOp = props.opacityBase ?? DMKeyframes.DEFAULT_BASE
            let midOp = props.opacityMid ?? DMKeyframes.DEFAULT_MID
            let peakOp = props.opacityPeak ?? DMKeyframes.DEFAULT_PEAK
            let rowStep = 0.10
            let colStep = 0.05
            let delayUnits = Double(ctx.row) * rowStep + Double(ctx.col) * colStep
            if ctx.reducedMotion || ctx.phase == .idle {
                let norm = 1.0 - delayUnits / (4 * rowStep + 4 * colStep)
                return baseOp + norm * (midOp - baseOp)
            }
            let cycleSec = 2.2
            let delay = delayUnits * cycleSec
            let t = DMKeyframes.phaseWithDelay(now: now, cycleSec: cycleSec, delaySec: delay)
            return DMKeyframes.tokenFall(t, base: baseOp, mid: midOp, peak: peakOp)
        }
    }
}
