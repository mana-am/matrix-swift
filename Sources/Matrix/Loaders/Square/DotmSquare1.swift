import SwiftUI

/// Diagonal alt sweep — `dmx-diagonal-alt-sweep` keyframe with delay = path*0.2 + parity*0.5.
struct DotmSquare1: View {
    var props = DotMatrixCommonProps(pattern: .full)
    var body: some View {
        DotMatrixBase(props: props, bypassOpacityRemap: true) { ctx, now in
            let baseOp = props.opacityBase ?? DMKeyframes.DEFAULT_BASE
            let peakOp = props.opacityPeak ?? DMKeyframes.DEFAULT_PEAK
            let path = DotMatrixGridPaths.trBlPathNormFromIndex(ctx.index)
            let slice = ctx.row + (4 - ctx.col)
            let parity = Double(slice % 2)
            if ctx.reducedMotion || ctx.phase == .idle {
                return parity == 0 ? peakOp : baseOp * 0.875
            }
            let cycleSec = 1.5
            let delay = (path * 0.2 + parity * 0.5) * cycleSec
            let t = DMKeyframes.phaseWithDelay(now: now, cycleSec: cycleSec, delaySec: delay)
            return DMKeyframes.diagonalAltSweep(t, base: baseOp, peak: peakOp)
        }
    }
}
