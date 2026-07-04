import SwiftUI

/// Orbit — head + 1-step tail orbiting 8 inner cells.
struct DotmCircular19: View {
    var props = DotMatrixCommonProps(pattern: .full)
    private static let BASE_OPACITY: Double = 0.07
    private static let MID_OPACITY: Double = 0.34
    private static let HIGH_OPACITY: Double = 0.95

    private static let ORBIT_POINTS: [(row: Int, col: Int)] = [
        (1, 1), (1, 2), (1, 3),
        (2, 3), (3, 3),
        (3, 2), (3, 1), (2, 1),
    ]

    var body: some View {
        DotMatrixBase(props: props) { ctx, now in
            guard isWithinCircularMask(row: ctx.row, col: ctx.col) else { return 0 }

            let phase = cyclePhase(now: now, cycleMsBase: 1280, speed: 1,
                                   active: !ctx.reducedMotion && ctx.phase != .idle)
            let t = ctx.reducedMotion || ctx.phase == .idle
                ? 0
                : Int(floor(phase * Double(Self.ORBIT_POINTS.count))) % Self.ORBIT_POINTS.count
            let head = Self.ORBIT_POINTS[t]
            let tail = Self.ORBIT_POINTS[(t + Self.ORBIT_POINTS.count - 1) % Self.ORBIT_POINTS.count]

            var opacity = Self.BASE_OPACITY
            if ctx.row == head.row && ctx.col == head.col {
                opacity = Self.HIGH_OPACITY
            } else if ctx.row == tail.row && ctx.col == tail.col {
                opacity = 0.62
            } else if (ctx.col == 1 || ctx.col == 3) && (ctx.row == 1 || ctx.row == 2 || ctx.row == 3) {
                opacity = Self.MID_OPACITY
            } else if ctx.row == 2 && ctx.col == 2 {
                opacity = 0.2
            }

            return opacity
        }
    }
}
