import SwiftUI

/// Strand + bridge — dual sinusoidal strands that weave and connect via rungs.
struct DotmCircular13: View {
    var props = DotMatrixCommonProps(pattern: .full)
    private static let STEP_COUNT: Int = 28
    private static let BASE_OPACITY: Double = 0.07
    private static let STRAND_OPACITY: Double = 0.95
    private static let NEAR_STRAND_OPACITY: Double = 0.5
    private static let BRIDGE_OPACITY: Double = 0.3

    var body: some View {
        DotMatrixBase(props: props) { ctx, now in
            guard isWithinCircularMask(row: ctx.row, col: ctx.col) else { return 0 }

            let x = Double(ctx.col - 2)
            let y = Double(ctx.row - 2)
            let step = steppedCycle(
                now: now, cycleMsBase: 1750, steps: Self.STEP_COUNT, speed: 1,
                active: !ctx.reducedMotion && ctx.phase != .idle)
            let t = ctx.reducedMotion || ctx.phase == .idle
                ? 0.0
                : Double(step) / Double(Self.STEP_COUNT) * .pi * 2

            // Two sinusoidal strands mirrored around x=0
            let strandOffset = sin(y * 1.35 + t * 1.3) * 1.15
            let leftStrand = -strandOffset
            let rightStrand = strandOffset
            let leftDistance = abs(x - leftStrand)
            let rightDistance = abs(x - rightStrand)
            let strandDistance = min(leftDistance, rightDistance)

            let bridgeOn = cos(y * 2 + t * 2.1) > 0.55
            let isBetweenStrands = x > min(leftStrand, rightStrand)
                && x < max(leftStrand, rightStrand)

            var opacity = Self.BASE_OPACITY
            if strandDistance < 0.34 {
                opacity = Self.STRAND_OPACITY
            } else if strandDistance < 0.8 {
                opacity = Self.NEAR_STRAND_OPACITY
            } else if bridgeOn && isBetweenStrands {
                opacity = Self.BRIDGE_OPACITY
            }

            return opacity
        }
    }
}
