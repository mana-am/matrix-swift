import SwiftUI

/// Triangle 16 — a V-shaped front rides up the two lower legs and meets at the
/// apex (convective lift), keyed on `row - wing·|col - 3|`. Cycle (2400ms).
/// Mirrors `dotm-triangle-16.tsx`.
struct DotmTriangle16: View {
    var props = DotMatrixCommonProps(size: 30, dotSize: 4, pattern: .full)

    private static let BASE_OPACITY = 0.1
    private static let MID_OPACITY = 0.36
    private static let HIGH_OPACITY = 0.96
    private static let WING = 0.52
    private static let FRONT_SIGMA = 0.88

    private static func opacityForCell(_ row: Int, _ col: Int, _ phase: Double) -> Double {
        let t = phase * Double.pi * 2
        let v = Double(row) - WING * abs(Double(col) - 3)
        let front = 1.85 + 1.4 * sin(t)
        let d = abs(v - front)
        let glowRaw = exp(-(d * d) / (FRONT_SIGMA * FRONT_SIGMA))
        let glow = dmHexSmoothstep01(0.04, 0.98, glowRaw)
        var opacity = BASE_OPACITY + glow * (HIGH_OPACITY - BASE_OPACITY)
        if row == 3 && col == 3 {
            opacity = max(opacity, MID_OPACITY * 0.58 + glow * (HIGH_OPACITY - MID_OPACITY) * 0.48)
        }
        return min(HIGH_OPACITY, opacity)
    }

    var body: some View {
        DotMatrixTriangleBase(props: props) { row, col, now, active in
            let phase = active ? cyclePhase(now: now, cycleMsBase: 2400, speed: 1, active: true) : 0.12
            return Self.opacityForCell(row, col, phase)
        }
    }
}
