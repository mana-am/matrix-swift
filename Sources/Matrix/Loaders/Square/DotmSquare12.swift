import SwiftUI

/// Center-origin ripple from corner (1,1). `dmx-center-origin-ripple`.
struct DotmSquare12: View {
    var props = DotMatrixCommonProps(pattern: .full)

    private static let ORIGIN_ROW: Int = 1
    private static let ORIGIN_COL: Int = 1
    private static let MAX_MANHATTAN: Int = 6

    var body: some View {
        DotMatrixBase(props: props, bypassOpacityRemap: true) { ctx, now in
            let baseOp = props.opacityBase ?? DMKeyframes.DEFAULT_BASE
            let midOp = props.opacityMid ?? DMKeyframes.DEFAULT_MID
            let peakOp = props.opacityPeak ?? DMKeyframes.DEFAULT_PEAK
            let rawRing = abs(ctx.row - Self.ORIGIN_ROW) + abs(ctx.col - Self.ORIGIN_COL)
            let ring = max(0, min(Self.MAX_MANHATTAN, rawRing))
            if ctx.reducedMotion || ctx.phase == .idle {
                let norm = 1.0 - Double(ring) / Double(Self.MAX_MANHATTAN)
                return baseOp + norm * (peakOp - baseOp)
            }
            let cycleSec = 1.5
            let delay = Double(ring) * 0.16 * cycleSec
            let t = DMKeyframes.phaseWithDelay(now: now, cycleSec: cycleSec, delaySec: delay)
            return DMKeyframes.centerOriginRipple(t, base: baseOp, mid: midOp, peak: peakOp)
        }
    }
}
