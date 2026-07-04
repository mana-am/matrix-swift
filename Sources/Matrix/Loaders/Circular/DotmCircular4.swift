import SwiftUI

/// Continuous angular sweep using projection onto a rotating axis.
struct DotmCircular4: View {
    var props = DotMatrixCommonProps(pattern: .full)
    private static let BASE_OPACITY: Double = 0.08
    private static let SWEEP_OPACITY: Double = 0.96
    private static let NEAR_SWEEP_OPACITY: Double = 0.36
    private static let RING_OPACITY: Double = 0.22

    var body: some View {
        DotMatrixBase(props: props) { ctx, now in
            guard isWithinCircularMask(row: ctx.row, col: ctx.col) else { return 0 }

            let centerRow = Double(ctx.row - 2)
            let centerCol = Double(ctx.col - 2)
            let radius = (centerRow * centerRow + centerCol * centerCol).squareRoot()
            let phaseVal = (ctx.reducedMotion || ctx.phase == .idle)
                ? 0.0
                : cyclePhase(now: now, cycleMsBase: 1800, speed: 1, active: true)
            let theta = phaseVal * .pi * 2
            let sweepX = cos(theta)
            let sweepY = sin(theta)
            let projection = centerCol * sweepX + centerRow * sweepY
            let perpendicular = abs(centerCol * sweepY - centerRow * sweepX)

            if radius < 0.5 {
                return 0.62
            }
            if projection > 0.3 && perpendicular < 0.55 {
                return Self.SWEEP_OPACITY
            }
            if projection > 0 && perpendicular < 1.15 {
                return Self.NEAR_SWEEP_OPACITY
            }
            if radius > 1.6 && radius < 2.3 {
                return Self.RING_OPACITY
            }
            return Self.BASE_OPACITY
        }
    }
}
