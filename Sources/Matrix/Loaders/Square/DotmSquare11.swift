import SwiftUI

/// Manhattan-distance ripple echo — `dmx-ripple-echo` keyframe.
struct DotmSquare11: View {
    var props = DotMatrixCommonProps(pattern: .full)
    var body: some View {
        DotMatrixBase(props: props, bypassOpacityRemap: true) { ctx, now in
            let baseOp = props.opacityBase ?? DMKeyframes.DEFAULT_BASE
            let midOp = props.opacityMid ?? DMKeyframes.DEFAULT_MID
            let peakOp = props.opacityPeak ?? DMKeyframes.DEFAULT_PEAK
            let ring = max(0, min(4, ctx.manhattanDistance))
            let parity = ring % 2
            if ctx.reducedMotion || ctx.phase == .idle {
                let norm = 1.0 - Double(ring) / 4.0
                return baseOp + norm * (peakOp - baseOp)
            }
            let cycleSec = 1.5
            let delay = (Double(ring) * 0.14 + Double(parity) * 0.03) * cycleSec
            let t = DMKeyframes.phaseWithDelay(now: now, cycleSec: cycleSec, delaySec: delay)
            return DMKeyframes.rippleEcho(t, base: baseOp, mid: midOp, peak: peakOp)
        }
    }
}
