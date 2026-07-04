import SwiftUI

/// Spoke pulse — rotating wedge beam with opposite ghost and diagonal spokes.
struct DotmCircular12: View {
    var props = DotMatrixCommonProps(pattern: .full)
    private static let STEP_COUNT: Int = 36
    private static let BASE_OPACITY: Double = 0.06
    private static let MID_OPACITY: Double = 0.3
    private static let ARC_OPACITY: Double = 0.96

    private static func ringTier(_ ring: Double) -> Int {
        if ring < 1 { return 0 }
        if ring < 2 { return 1 }
        return 2
    }

    var body: some View {
        DotMatrixBase(props: props) { ctx, now in
            guard isWithinCircularMask(row: ctx.row, col: ctx.col) else { return 0 }

            let x: Double = Double(ctx.col) - 2.0
            let y: Double = Double(ctx.row) - 2.0
            let ring: Double = (x * x + y * y).squareRoot()
            let angle: Double = atan2(y, x)
            let isActive = !ctx.reducedMotion && ctx.phase != .idle
            let step: Int = steppedCycle(
                now: now, cycleMsBase: 1700, steps: Self.STEP_COUNT, speed: 1,
                active: isActive
            )

            let stepFraction: Double = Double(step) / Double(Self.STEP_COUNT)
            let stepBand: Int = Int(floor(stepFraction * 8.0)) % 8
            let targetAngle: Double = Double(stepBand) * (.pi / 4.0)
            let angleDelta: Double = acos(cos(angle - targetAngle))
            let beam: Double = max(0.0, 1.0 - angleDelta / 0.42)

            let oppAngle: Double = targetAngle + .pi
            let oppDelta: Double = acos(cos(angle - oppAngle))
            let oppositeBeam: Double = max(0.0, 1.0 - oppDelta / 0.62)

            let absDiff: Double = abs(abs(x) - abs(y))
            let spokePulse: Double = max(0.0, 1.0 - absDiff / 0.35)
            let tier: Int = Self.ringTier(ring)

            var opacity: Double = Self.BASE_OPACITY
            if beam > 0.78 && tier >= 1 {
                opacity = Self.ARC_OPACITY
            } else if beam > 0.48 {
                opacity = 0.62
            } else if oppositeBeam > 0.52 && tier == 2 {
                opacity = Self.MID_OPACITY
            } else if spokePulse > 0.9 && tier > 0 {
                opacity = Self.MID_OPACITY
            }

            if x == 0.0 && y == 0.0 {
                return max(opacity, 0.26)
            }
            return opacity
        }
    }
}
