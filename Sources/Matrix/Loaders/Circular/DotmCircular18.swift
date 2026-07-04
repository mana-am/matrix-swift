import SwiftUI

/// Pulse pair — mirrored top/bottom rows pulsing at cols 1/3.
struct DotmCircular18: View {
    var props = DotMatrixCommonProps(pattern: .full)
    private static let BASE_OPACITY: Double = 0.07
    private static let MID_OPACITY: Double = 0.33
    private static let HIGH_OPACITY: Double = 0.95

    var body: some View {
        DotMatrixBase(props: props) { ctx, now in
            guard isWithinCircularMask(row: ctx.row, col: ctx.col) else { return 0 }

            let animPhase = cyclePhase(now: now, cycleMsBase: 1550, speed: 1,
                                       active: !ctx.reducedMotion && ctx.phase != .idle)
            let t = ctx.reducedMotion || ctx.phase == .idle
                ? 0
                : Int(floor(animPhase * 6))
            let pulseRow = t % 3
            let topRow = pulseRow
            let bottomRow = 4 - pulseRow
            let pairCols: Set<Int> = [1, 3]
            let onActiveRow = ctx.row == topRow || ctx.row == bottomRow

            var opacity = Self.BASE_OPACITY
            if onActiveRow && pairCols.contains(ctx.col) {
                opacity = Self.HIGH_OPACITY
            } else if onActiveRow && ctx.col == 2 {
                opacity = 0.58
            } else if (ctx.row == 2 || ctx.col == 2) && !pairCols.contains(ctx.col) {
                opacity = Self.MID_OPACITY
            } else if pairCols.contains(ctx.col) {
                opacity = 0.22
            }

            return opacity
        }
    }
}
