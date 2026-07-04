import SwiftUI

/// Hexagon outline rotating clockwise — each border cell fires in CW order via the
/// outerRingClockwise path, with mid-row cells (left/right) bridging the loop.
struct DotmFunHexagon: View {
    var props = DotMatrixCommonProps(pattern: .hexagon)

    /// Manually-ordered traversal of the hexagon perimeter clockwise from top-left.
    private static let CW_ORDER: [Int] = [
        1, 2, 3,        // top edge L→R
        9, 14, 19,      // right side T→B
        23, 22, 21,     // bottom edge R→L
        15, 10, 5,      // left side B→T
    ]

    var body: some View {
        DotMatrixBase(props: props, bypassOpacityRemap: true) { ctx, now in
            let baseOp = props.opacityBase ?? DMKeyframes.DEFAULT_BASE
            let midOp = props.opacityMid ?? DMKeyframes.DEFAULT_MID
            let peakOp = props.opacityPeak ?? DMKeyframes.DEFAULT_PEAK
            let order = Self.CW_ORDER.firstIndex(of: ctx.index) ?? 0
            let norm = Double(order) / Double(Self.CW_ORDER.count - 1)
            if ctx.reducedMotion || ctx.phase == .idle {
                return baseOp + norm * (peakOp - baseOp)
            }
            let cycleSec = 1.5
            let delay = norm * 0.85 * cycleSec
            let t = DMKeyframes.phaseWithDelay(now: now, cycleSec: cycleSec, delaySec: delay)
            return DMKeyframes.ringSnake(t, base: baseOp, mid: midOp, peak: peakOp)
        }
    }
}
