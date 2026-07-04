import SwiftUI

/// Right-pointing arrow whose dots ripple from tail to head — visually says "answer
/// flowing". Delay is keyed off column so the wave moves left → right.
struct DotmFunArrow: View {
    var props = DotMatrixCommonProps(pattern: .arrowRight)
    var body: some View {
        DotMatrixBase(props: props, bypassOpacityRemap: true) { ctx, now in
            let baseOp = props.opacityBase ?? DMKeyframes.DEFAULT_BASE
            let peakOp = props.opacityPeak ?? DMKeyframes.DEFAULT_PEAK
            let norm = Double(ctx.col) / 4.0  // 0 (tail) … 1 (head)
            if ctx.reducedMotion || ctx.phase == .idle {
                return baseOp + norm * (peakOp - baseOp)
            }
            let cycleSec = 1.4
            let delay = (1.0 - norm) * 0.4 * cycleSec  // head fires earliest, tail trails behind
            let t = DMKeyframes.phaseWithDelay(now: now, cycleSec: cycleSec, delaySec: delay)
            return DMKeyframes.ripple(t, base: baseOp, peak: peakOp)
        }
    }
}
