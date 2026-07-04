import SwiftUI

/// Triangle 15 — energy orbits the three vertices (apex → left base → right base)
/// with soft Manhattan falloff. Cycle (1100ms). Mirrors `dotm-triangle-15.tsx`.
struct DotmTriangle15: View {
    var props = DotMatrixCommonProps(size: 30, dotSize: 4, pattern: .full)

    private static let BASE_OPACITY = 0.08
    private static let MID_OPACITY = 0.38
    private static let HIGH_OPACITY = 0.96
    private static let HUBS: [(Int, Int)] = [(1, 3), (4, 0), (4, 6)]

    private static func falloffFromHub(_ row: Int, _ col: Int, _ hub: (Int, Int)) -> Double {
        let d = Double(abs(row - hub.0) + abs(col - hub.1))
        return 1 - dmHexSmoothstep01(0, 5.4, d)
    }

    private static func opacityForCell(_ row: Int, _ col: Int, _ phase: Double) -> Double {
        let t = phase * Double.pi * 2
        let sharp = 4.0
        let u0 = pow(max(0, cos(t)), sharp)
        let u1 = pow(max(0, cos(t - (Double.pi * 2) / 3)), sharp)
        let u2 = pow(max(0, cos(t - (Double.pi * 4) / 3)), sharp)
        let sum = u0 + u1 + u2 + 1e-4

        let glowA = falloffFromHub(row, col, HUBS[0])
        let glowB = falloffFromHub(row, col, HUBS[1])
        let glowC = falloffFromHub(row, col, HUBS[2])
        let glow = (glowA * u0 + glowB * u1 + glowC * u2) / sum

        var opacity = BASE_OPACITY + glow * (HIGH_OPACITY - BASE_OPACITY)
        if row == 3 && col == 3 {
            opacity = max(opacity, MID_OPACITY + glow * 0.32)
        }
        return min(HIGH_OPACITY, opacity)
    }

    var body: some View {
        DotMatrixTriangleBase(props: props) { row, col, now, active in
            let phase = active ? cyclePhase(now: now, cycleMsBase: 1100, speed: 1, active: true) : 0.15
            return Self.opacityForCell(row, col, phase)
        }
    }
}
