import SwiftUI

/// Fill / drain bars + blink. 24-step sequence.
struct DotmSquare8: View {
    var props = DotMatrixCommonProps(pattern: .full)

    private static let ROWS = 5
    private static let COLS = 5
    private static let FILL_LAST = ROWS + COLS - 1   // 9
    private static let BLINK_STEPS = 4
    private static let DRAIN_LAST = FILL_LAST        // 9
    private static let SEQUENCE_LEN = FILL_LAST + 1 + BLINK_STEPS + DRAIN_LAST + 1  // 24

    private static let BLINK_OPACITIES: [Double] = [0.38, 1, 0.38, 1]
    private static let BASE_OPACITY: Double = 0.08
    private static let SETTLED_OPACITY: Double = 0.52
    private static let CAP_OPACITY: Double = 1

    private static func fillHeight(col: Int, fillTick: Int) -> Int {
        max(0, min(ROWS, fillTick - col))
    }

    private static func drainHeight(col: Int, drainTick: Int) -> Int {
        max(0, min(ROWS, ROWS - max(0, drainTick - col)))
    }

    var body: some View {
        DotMatrixBase(props: props) { ctx, now in
            if ctx.reducedMotion || ctx.phase == .idle { return Self.BASE_OPACITY }

            let step = steppedCycle(
                now: now, cycleMsBase: 2000, steps: Self.SEQUENCE_LEN, speed: 1, active: true)

            var height = 0
            var blinkOpacity: Double? = nil

            if step <= Self.FILL_LAST {
                height = Self.fillHeight(col: ctx.col, fillTick: step)
            } else if step < Self.FILL_LAST + 1 + Self.BLINK_STEPS {
                height = Self.ROWS
                blinkOpacity = Self.BLINK_OPACITIES[step - (Self.FILL_LAST + 1)]
            } else {
                let drainTick = step - (Self.FILL_LAST + 1 + Self.BLINK_STEPS)
                height = Self.drainHeight(col: ctx.col, drainTick: drainTick)
            }

            let bottomRow = Self.ROWS - 1
            let topLitRow = Self.ROWS - height
            let isLit = height > 0 && ctx.row >= topLitRow && ctx.row <= bottomRow
            if !isLit { return Self.BASE_OPACITY }

            if let blink = blinkOpacity { return blink }

            let isCap = ctx.row == topLitRow && height > 0 && height < Self.ROWS
            return isCap ? Self.CAP_OPACITY : Self.SETTLED_OPACITY
        }
    }
}
