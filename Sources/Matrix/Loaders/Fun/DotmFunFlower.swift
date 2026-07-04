import SwiftUI

/// Flower — petals and inner cross alternate brightness on a slow cycle. Each "petal" is
/// keyed off its polar angle so the bloom appears to rotate.
struct DotmFunFlower: View {
    var props = DotMatrixCommonProps(pattern: .flower)
    var body: some View {
        DotMatrixBase(props: props, bypassOpacityRemap: true) { ctx, now in
            let baseOp = props.opacityBase ?? DMKeyframes.DEFAULT_BASE
            let midOp = props.opacityMid ?? DMKeyframes.DEFAULT_MID
            let peakOp = props.opacityPeak ?? DMKeyframes.DEFAULT_PEAK
            let isCenter = ctx.row == 2 && ctx.col == 2
            if isCenter {
                // Inner core breathes opposite the petals to give a "pulsing pistil".
                if ctx.reducedMotion || ctx.phase == .idle { return peakOp }
                let cycleSec = 2.4
                let t = DMKeyframes.phaseWithDelay(now: now, cycleSec: cycleSec, delaySec: 0)
                return DMKeyframes.breathing(t, base: midOp, peak: peakOp)
            }
            // Petals: delay = polar angle / 2π, so they fire in a rotating order.
            let angle = ctx.polarAngle  // -π…π
            let normAngle = (angle + .pi) / (2 * .pi)  // 0…1 starting at "left"
            if ctx.reducedMotion || ctx.phase == .idle {
                return baseOp + normAngle * (peakOp - baseOp) * 0.7
            }
            let cycleSec = 2.4
            let delay = normAngle * cycleSec
            let t = DMKeyframes.phaseWithDelay(now: now, cycleSec: cycleSec, delaySec: delay)
            return DMKeyframes.ripple(t, base: baseOp, peak: peakOp)
        }
    }
}
