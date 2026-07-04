import SwiftUI

/// Diagonal snake — `dmx-diagonal-snake` keyframe with delay = order * 0.04.
struct DotmSquare5: View {
    var props = DotMatrixCommonProps(pattern: .full)
    var body: some View {
        DotMatrixBase(props: props, bypassOpacityRemap: true) { ctx, now in
            let baseOp = props.opacityBase ?? DMKeyframes.DEFAULT_BASE
            let midOp = props.opacityMid ?? DMKeyframes.DEFAULT_MID
            let peakOp = props.opacityPeak ?? DMKeyframes.DEFAULT_PEAK
            let order = DotMatrixGridPaths.diagonalSnakeOrderValue(ctx.index)
            let norm = DotMatrixGridPaths.diagonalSnakeNormFromIndex(ctx.index)
            if ctx.reducedMotion || ctx.phase == .idle {
                return baseOp + norm * (peakOp - baseOp)
            }
            let cycleSec = 1.5
            let delay = Double(order) * 0.04 * cycleSec
            let t = DMKeyframes.phaseWithDelay(now: now, cycleSec: cycleSec, delaySec: delay)
            return DMKeyframes.diagonalSnake(t, base: baseOp, mid: midOp, peak: peakOp)
        }
    }
}
