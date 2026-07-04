import SwiftUI

/// Triangle 7 — sliding diagonal bands: cells sharing `row + col` pulse together
/// so stripes read as continuous diagonals. Cycle (2200ms).
/// Mirrors `dotm-triangle-7.tsx`.
struct DotmTriangle7: View {
    var props = DotMatrixCommonProps(size: 30, dotSize: 4, pattern: .full)

    private static let BASE_OPACITY = 0.06
    private static let MID_OPACITY = 0.38
    private static let HIGH_OPACITY = 0.96

    private static func opacityForCell(_ row: Int, _ col: Int, _ phase: Double) -> Double {
        let diag = Double(row + col)
        let t = phase * Double.pi * 2
        let u = diag * 0.55 - t * 1.35
        let primary = 0.5 + 0.5 * cos(u)
        let harmonic = 0.5 + 0.5 * cos(u * 2 + 0.4)
        let crest = primary * primary * 0.92 + max(0, harmonic - 0.35) * 0.28
        var opacity = BASE_OPACITY + crest * (HIGH_OPACITY - BASE_OPACITY)
        if row == 3 && col == 3 {
            opacity = max(opacity, MID_OPACITY + (crest - 0.25) * 0.35)
        }
        return min(HIGH_OPACITY, opacity)
    }

    var body: some View {
        DotMatrixTriangleBase(props: props) { row, col, now, active in
            let phase = active ? cyclePhase(now: now, cycleMsBase: 2200, speed: 1, active: true) : 0.22
            return Self.opacityForCell(row, col, phase)
        }
    }
}
