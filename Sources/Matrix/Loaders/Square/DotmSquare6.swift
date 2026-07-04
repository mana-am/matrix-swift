import SwiftUI

/// Column snake — `dmx-square6-col-snake` keyframe. Columns alternate up/down.
struct DotmSquare6: View {
    var props = DotMatrixCommonProps(pattern: .full)

    private static let COLUMN_HEIGHT = 5

    var body: some View {
        DotMatrixBase(props: props, bypassOpacityRemap: true) { ctx, now in
            let baseOp = props.opacityBase ?? DMKeyframes.DEFAULT_BASE
            let midOp = props.opacityMid ?? DMKeyframes.DEFAULT_MID
            let peakOp = props.opacityPeak ?? DMKeyframes.DEFAULT_PEAK
            let goesUp = ctx.col % 2 == 0
            let position = goesUp ? (Self.COLUMN_HEIGHT - 1 - ctx.row) : ctx.row
            if ctx.reducedMotion || ctx.phase == .idle {
                let norm = Double(position) / Double(Self.COLUMN_HEIGHT - 1)
                return baseOp + norm * (peakOp - baseOp) * 0.85
            }
            let cycleSec = 1.5
            let delay = Double(position) * 0.2 * cycleSec
            let t = DMKeyframes.phaseWithDelay(now: now, cycleSec: cycleSec, delaySec: delay)
            return DMKeyframes.square6ColSnake(t, base: baseOp, mid: midOp, peak: peakOp)
        }
    }
}
