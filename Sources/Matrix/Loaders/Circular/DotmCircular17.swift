import SwiftUI

/// Checker shift with Braille bias on cols 1/3 and center bias.
struct DotmCircular17: View {
    var props = DotMatrixCommonProps(pattern: .full)
    /// Discrete checker frames per loop (must stay integer for `(row + col + t) % 2`).
    private static let CHECKER_STEPS: Int = 4
    private static let BASE_OPACITY: Double = 0.07
    private static let MID_OPACITY: Double = 0.34
    private static let HIGH_OPACITY: Double = 0.95

    var body: some View {
        DotMatrixBase(props: props) { ctx, now in
            guard isWithinCircularMask(row: ctx.row, col: ctx.col) else { return 0 }

            let holdStill = ctx.reducedMotion || ctx.phase == .idle
            let animPhase = cyclePhase(now: now, cycleMsBase: 1500, speed: 1,
                                       active: !ctx.reducedMotion && ctx.phase != .idle)
            let t = holdStill
                ? 0
                : Int(floor(animPhase * Double(Self.CHECKER_STEPS))) % Self.CHECKER_STEPS
            let parity = (ctx.row + ctx.col + t) % 2
            let brailleBias = ctx.col == 1 || ctx.col == 3
            let centerBias = ctx.row == 2 || ctx.col == 2

            var opacity = Self.BASE_OPACITY
            if parity == 0 && brailleBias {
                opacity = Self.HIGH_OPACITY
            } else if parity == 0 || centerBias {
                opacity = Self.MID_OPACITY
            } else if brailleBias {
                opacity = 0.24
            }

            return opacity
        }
    }
}
