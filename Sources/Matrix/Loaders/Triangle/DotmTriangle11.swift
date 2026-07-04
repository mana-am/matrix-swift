import SwiftUI

/// Triangle 11 — bright shelves descend by tier keyed on Manhattan distance from
/// the apex (1,3). Cycle (1400ms). Mirrors `dotm-triangle-11.tsx`.
struct DotmTriangle11: View {
    var props = DotMatrixCommonProps(size: 30, dotSize: 4, pattern: .full)

    private static let BASE_OPACITY = 0.13
    private static let MID_OPACITY = 0.36
    private static let HIGH_OPACITY = 0.96
    private static let APEX_ROW = 1
    private static let APEX_COL = 3

    private static func opacityForCell(_ row: Int, _ col: Int, _ phase: Double) -> Double {
        let tier = Double(abs(row - APEX_ROW) + abs(col - APEX_COL))
        let maxTier = 6.0
        let t = phase * Double.pi * 2
        let u = (tier / maxTier) * Double.pi * 2 - t
        let wave = 0.5 + 0.5 * cos(u)
        let crest = dmHexSmoothstep01(0.28, 0.98, wave)
        var opacity = BASE_OPACITY + crest * (HIGH_OPACITY - BASE_OPACITY)
        if row == 3 && col == 3 {
            opacity = max(opacity, MID_OPACITY + crest * 0.35)
        }
        return min(HIGH_OPACITY, opacity)
    }

    var body: some View {
        DotMatrixTriangleBase(props: props) { row, col, now, active in
            let phase = active ? cyclePhase(now: now, cycleMsBase: 1400, speed: 1, active: true) : 0.18
            return Self.opacityForCell(row, col, phase)
        }
    }
}
