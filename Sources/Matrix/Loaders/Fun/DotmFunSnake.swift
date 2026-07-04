import SwiftUI

/// A 3-cell snake (head + 2 trailing) chases its own tail along a boustrophedon path.
/// JS-step style: at each step `s`, the cells with snake-order ∈ {s, s-1, s-2} (mod 25)
/// are lit at peak / mid / base.
struct DotmFunSnake: View {
    var props = DotMatrixCommonProps(pattern: .full)
    private static let SNAKE_LEN = 3
    private static let TOTAL = 25
    private static let CYCLE_SEC: Double = 2.5
    private static let STEPS = TOTAL  // one cell per step

    var body: some View {
        DotMatrixBase(props: props, bypassOpacityRemap: true) { ctx, now in
            let baseOp = props.opacityBase ?? DMKeyframes.DEFAULT_BASE
            let midOp = props.opacityMid ?? DMKeyframes.DEFAULT_MID
            let peakOp = props.opacityPeak ?? DMKeyframes.DEFAULT_PEAK
            let order = DotMatrixGridPaths.snakePathOrderValue(ctx.index)
            if ctx.reducedMotion || ctx.phase == .idle {
                let norm = Double(order) / Double(Self.TOTAL - 1)
                return baseOp + norm * (peakOp - baseOp) * 0.4
            }
            let phase = (now.truncatingRemainder(dividingBy: Self.CYCLE_SEC)) / Self.CYCLE_SEC
            let head = Int(floor(phase * Double(Self.STEPS))) % Self.TOTAL
            // Distance "behind the head" along the snake path.
            var distBehind = head - order
            if distBehind < 0 { distBehind += Self.TOTAL }
            switch distBehind {
            case 0: return peakOp                    // head
            case 1: return 0.7 * peakOp + 0.3 * midOp
            case 2: return midOp                     // tail
            default: return baseOp
            }
        }
    }
}
