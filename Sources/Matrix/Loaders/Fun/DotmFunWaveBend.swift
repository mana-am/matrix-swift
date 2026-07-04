import SwiftUI

/// A horizontal ripple bent by a "magnet" point that drifts in a Lissajous orbit. Each
/// cell's effective phase is shifted by its proximity to the magnet, so the wavefront
/// curls and uncurls organically.
struct DotmFunWaveBend: View {
    var props = DotMatrixCommonProps(pattern: .full)
    var body: some View {
        DotMatrixBase(props: props, bypassOpacityRemap: true) { ctx, now in
            let baseOp = props.opacityBase ?? DMKeyframes.DEFAULT_BASE
            let midOp = props.opacityMid ?? DMKeyframes.DEFAULT_MID
            let peakOp = props.opacityPeak ?? DMKeyframes.DEFAULT_PEAK
            // Magnet position drifts on a Lissajous curve over 5 seconds.
            let orbitSec = 5.0
            let phi = (now.truncatingRemainder(dividingBy: orbitSec)) / orbitSec
            let mx = 2.0 + 1.8 * sin(2 * .pi * phi)        // 0.2…3.8
            let my = 2.0 + 1.6 * sin(2 * .pi * 1.5 * phi)  // 0.4…3.6

            let dx = Double(ctx.col) - mx
            let dy = Double(ctx.row) - my
            let distSq = dx * dx + dy * dy
            // Magnet warp adds 0…0.45 of cycleSec to the cell's phase.
            let warp = 0.45 * exp(-distSq / 4.0)

            if ctx.reducedMotion || ctx.phase == .idle {
                return baseOp + (1 - warp / 0.45) * (peakOp - baseOp) * 0.6
            }
            let cycleSec = 2.0
            let baseDelay = Double(ctx.col) / 4.0 * 0.5 * cycleSec
            let delay = baseDelay + warp * cycleSec
            let t = DMKeyframes.phaseWithDelay(now: now, cycleSec: cycleSec, delaySec: delay)
            return DMKeyframes.rippleEcho(t, base: baseOp, mid: midOp, peak: peakOp)
        }
    }
}
