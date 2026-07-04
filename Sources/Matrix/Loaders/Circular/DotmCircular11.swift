import SwiftUI

/// Lunar breathe — moon-cut disk that orbits and casts a halo trail.
struct DotmCircular11: View {
    var props = DotMatrixCommonProps(pattern: .full)
    private static let BASE_OPACITY: Double = 0.07
    private static let MID_OPACITY: Double = 0.3
    private static let HIGH_OPACITY: Double = 0.95

    var body: some View {
        DotMatrixBase(props: props) { ctx, now in
            guard isWithinCircularMask(row: ctx.row, col: ctx.col) else { return 0 }

            let x = Double(ctx.col - 2)
            let y = Double(ctx.row - 2)
            let ring = (x * x + y * y).squareRoot()
            let phaseVal = (ctx.reducedMotion || ctx.phase == .idle)
                ? 0.0
                : cyclePhase(now: now, cycleMsBase: 1850, speed: 1, active: true)
            let t = phaseVal * .pi * 2
            let angle = atan2(y, x)

            // Moon disk center orbits at radius 0.7
            let moonCenterX = cos(t) * 0.7
            let moonCenterY = sin(t) * 0.7
            let bodyDist = ((x - moonCenterX) * (x - moonCenterX) + (y - moonCenterY) * (y - moonCenterY)).squareRoot()

            // Cut circle center is offset further along the same direction
            let cutCenterX = moonCenterX + cos(t) * 0.82
            let cutCenterY = moonCenterY + sin(t) * 0.82
            let cutDist = ((x - cutCenterX) * (x - cutCenterX) + (y - cutCenterY) * (y - cutCenterY)).squareRoot()

            let rim = max(0, 1 - abs(bodyDist - 1.55) / 0.35)
            let halo = max(0, 1 - acos(cos(angle - t)) / 0.9)

            var opacity = Self.BASE_OPACITY
            if bodyDist < 1.55 && cutDist > 1.05 {
                opacity = Self.HIGH_OPACITY
            } else if rim > 0.5 {
                opacity = Self.MID_OPACITY + rim * 0.22
            } else if halo > 0.68 && ring > 1.2 {
                opacity = Self.MID_OPACITY
            }

            return min(Self.HIGH_OPACITY, opacity)
        }
    }
}
