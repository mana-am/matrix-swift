import SwiftUI

/// Triangle 3 — a rotating radar beam sweeps the silhouette with a soft trailing
/// glow and an ambient pulse. Stepped cycle (36 steps, 1650ms).
/// Mirrors `dotm-triangle-3.tsx`.
struct DotmTriangle3: View {
    var props = DotMatrixCommonProps(size: 30, dotSize: 4, pattern: .full)

    private static let STEP_COUNT = 36
    private static let BASE_OPACITY = 0.03
    private static let MID_OPACITY = 0.07
    private static let HIGH_OPACITY = 0.94
    private static let FAR_OPACITY = 0.15

    var body: some View {
        DotMatrixTriangleBase(props: props) { row, col, now, active in
            let frame = steppedCycle(
                now: now, cycleMsBase: 1650, steps: Self.STEP_COUNT, speed: 1, active: active)
            let theta = (Double(frame) / Double(Self.STEP_COUNT)) * Double.pi * 2
            let sweepX = cos(theta)
            let sweepY = sin(theta)
            let ambientPulse = 0.5 - 0.5 * cos(theta)

            let centerRow = Double(row - 3)
            let centerCol = Double(col - 3)
            let radius = hypot(centerRow, centerCol)
            let projection = centerCol * sweepX + centerRow * sweepY
            let perpendicular = abs(centerCol * sweepY - centerRow * sweepX)
            let ahead = max(0, projection)
            let beamCore = max(0, 1 - perpendicular / 0.45)
            let beamHalo = max(0, 1 - perpendicular / 1.15)
            let rangeFade = max(0.25, 1 - radius / 3.6)
            let trail = beamHalo * max(0, 1 - ahead / 3.6)

            var opacity = Self.BASE_OPACITY + ambientPulse * (Self.MID_OPACITY - Self.BASE_OPACITY) * rangeFade
            opacity = max(opacity, Self.MID_OPACITY + beamCore * (Self.HIGH_OPACITY - Self.MID_OPACITY))
            opacity = max(opacity, Self.FAR_OPACITY + trail * (Self.MID_OPACITY - Self.FAR_OPACITY))
            if row == 3 && col == 3 { opacity = max(opacity, 0.56) }
            opacity = min(Self.HIGH_OPACITY, opacity)
            return opacity
        }
    }
}
