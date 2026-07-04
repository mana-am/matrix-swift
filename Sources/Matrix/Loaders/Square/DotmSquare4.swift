import SwiftUI

/// Dual-ring: outer ring CW + middle ring CCW — `dmx-outer-snake` + `dmx-middle-snake`.
struct DotmSquare4: View {
    var props = DotMatrixCommonProps(pattern: .full)
    var body: some View {
        DotMatrixBase(props: props, bypassOpacityRemap: true) { ctx, now in
            let baseOp = props.opacityBase ?? DMKeyframes.DEFAULT_BASE
            let midOp = props.opacityMid ?? DMKeyframes.DEFAULT_MID
            let peakOp = props.opacityPeak ?? DMKeyframes.DEFAULT_PEAK

            let isCenter = ctx.row == 2 && ctx.col == 2
            if isCenter { return 0.0 }

            let outerOrder = DotMatrixGridPaths.outerRingClockwiseOrderValue(ctx.index)
            if outerOrder >= 0 {
                let outerNorm = DotMatrixGridPaths.outerRingClockwiseNormFromIndex(ctx.index)
                if ctx.reducedMotion || ctx.phase == .idle {
                    return baseOp + outerNorm * (peakOp - baseOp)
                }
                let cycleSec = 1.5
                let delay = Double(outerOrder) * 0.0625 * cycleSec
                let t = DMKeyframes.phaseWithDelay(now: now, cycleSec: cycleSec, delaySec: delay)
                return DMKeyframes.ringSnake(t, base: baseOp, mid: midOp, peak: peakOp)
            }

            let middleOrder = DotMatrixGridPaths.middleRingAntiClockwiseOrderValue(ctx.index)
            let middleNorm = DotMatrixGridPaths.middleRingAntiClockwiseNormFromIndex(ctx.index)
            if ctx.reducedMotion || ctx.phase == .idle {
                return baseOp + middleNorm * (peakOp - baseOp)
            }
            let cycleSec = 1.5
            let delay = Double(middleOrder) * 0.125 * cycleSec
            let t = DMKeyframes.phaseWithDelay(now: now, cycleSec: cycleSec, delaySec: delay)
            return DMKeyframes.ringSnake(t, base: baseOp, mid: midOp, peak: peakOp)
        }
    }
}
