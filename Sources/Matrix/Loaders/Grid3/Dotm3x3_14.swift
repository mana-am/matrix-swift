import SwiftUI

/// 3×3 frame chase (stepped) — a head walks the outer ring with a 3-level fading
/// tail while the center flickers. Stepped cycle (8 steps, 1150ms); fully
/// JS-computed opacity (remapped). Mirrors `dotm-3x3-14.tsx` (speed 1.6).
struct Dotm3x3_14: View {
    var props = DotMatrixCommonProps(speed: 1.6, pattern: .full)

    private static let BASE_OPACITY = 0.06
    private static let TAIL_LEVELS: [Double] = [0.92, 0.52, 0.24]
    private static let PERIMETER = 8

    var body: some View {
        DotMatrix3Base(props: props) { ctx, now in
            let active = ctx.phase != .idle && !ctx.reducedMotion
            let step = steppedCycle(
                now: now, cycleMsBase: 1150, steps: Self.PERIMETER, speed: 1, active: active)
            let head = step % Self.PERIMETER

            if DotMatrix3GridPaths.isCenterCell(row: ctx.row, col: ctx.col) {
                return active ? 0.1 + Double(head % 2) * 0.08 : 0.18
            }

            let order = DotMatrix3GridPaths.outerRingClockwiseOrderValue(ctx.index)
            if order < 0 { return Self.BASE_OPACITY }

            let trail = (head - order + Self.PERIMETER) % Self.PERIMETER
            var opacity = Self.BASE_OPACITY
            for i in 0..<Self.TAIL_LEVELS.count where trail == i {
                opacity = Self.BASE_OPACITY + Self.TAIL_LEVELS[i] * 0.82
                break
            }
            return opacity
        }
    }
}
