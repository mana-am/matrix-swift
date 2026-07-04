import SwiftUI

/// 3-sector pulse with ring phase blend.
struct DotmCircular6: View {
    var props = DotMatrixCommonProps(pattern: .full)
    private static let BASE_OPACITY: Double = 0.08
    private static let ORBIT_OPACITY: Double = 0.96
    private static let NEAR_ORBIT_OPACITY: Double = 0.34

    var body: some View {
        DotMatrixBase(props: props) { ctx, now in
            guard isWithinCircularMask(row: ctx.row, col: ctx.col) else { return 0 }

            let x = Double(ctx.col - 2)
            let y = Double(ctx.row - 2)
            let phaseVal = (ctx.reducedMotion || ctx.phase == .idle)
                ? 0.0
                : cyclePhase(now: now, cycleMsBase: 1700, speed: 1, active: true)
            let t = phaseVal * .pi * 2
            let angle = atan2(y, x)
            let ring = (x * x + y * y).squareRoot()

            // Split into named locals to avoid type-checker timeout
            let rawAngPhase = (angle - t * 0.95 + .pi * 4).truncatingRemainder(dividingBy: .pi * 2)
            let normalized = rawAngPhase / (.pi * 2 / 3)
            let sectorPos = normalized - floor(normalized)
            let sectorPulse = max(0, 1 - abs(sectorPos - 0.5) * 2)
            let ringPhase = 0.5 + 0.5 * cos(ring * 3.2 + t * 1.7)
            let score = 0.74 * sectorPulse + 0.26 * ringPhase

            var opacity = Self.BASE_OPACITY
            if score > 0.84 {
                opacity = Self.ORBIT_OPACITY
            } else if score > 0.63 {
                opacity = 0.62
            } else if score > 0.44 {
                opacity = Self.NEAR_ORBIT_OPACITY
            }

            if x == 0 && y == 0 {
                return max(opacity, Self.NEAR_ORBIT_OPACITY)
            }
            return opacity
        }
    }
}
