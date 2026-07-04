import SwiftUI

/// Triangle 14 — a soft vertical pillar of brightness sweeps column 0→6; only
/// masked dots respond, so the triangle lights one vertical slice at a time.
/// Cycle (1500ms). Mirrors `dotm-triangle-14.tsx`.
struct DotmTriangle14: View {
    var props = DotMatrixCommonProps(size: 30, dotSize: 4, pattern: .full)

    private static let BASE_OPACITY = 0.07
    private static let MID_OPACITY = 0.32
    private static let HIGH_OPACITY = 0.96

    private static func opacityForCell(_ row: Int, _ col: Int, _ phase: Double) -> Double {
        let beamCenter = phase * 7.2 - 0.35
        let dist = abs(Double(col) - beamCenter)
        let core = 1 - dmHexSmoothstep01(0, 0.62, dist)
        let halo = 1 - dmHexSmoothstep01(0.35, 1.42, dist)
        let eased = core * 0.92 + halo * 0.22
        var opacity = BASE_OPACITY + eased * (HIGH_OPACITY - BASE_OPACITY)
        if row == 3 && col == 3 {
            opacity = max(opacity, MID_OPACITY + eased * 0.28)
        }
        return min(HIGH_OPACITY, opacity)
    }

    var body: some View {
        DotMatrixTriangleBase(props: props) { row, col, now, active in
            let phase = active ? cyclePhase(now: now, cycleMsBase: 1500, speed: 1, active: true) : 0.12
            return Self.opacityForCell(row, col, phase)
        }
    }
}
