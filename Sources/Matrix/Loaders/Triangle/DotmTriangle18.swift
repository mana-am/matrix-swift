import SwiftUI

/// Triangle 18 — the heart cell stays dim while the outer shell breathes in sync
/// (inverted emphasis vs center-led coronas). Cycle (1600ms).
/// Mirrors `dotm-triangle-18.tsx`.
struct DotmTriangle18: View {
    var props = DotMatrixCommonProps(size: 30, dotSize: 4, pattern: .full)

    private static let CORE_DIM = 0.1
    private static let SHELL_LOW = 0.22
    private static let SHELL_HIGH = 0.96

    private static func opacityForCell(_ row: Int, _ col: Int, _ phase: Double) -> Double {
        if row == 3 && col == 3 { return CORE_DIM }
        let breathe = 0.5 + 0.5 * sin(phase * Double.pi * 2)
        let crest = dmHexSmoothstep01(0.2, 0.94, breathe)
        return SHELL_LOW + crest * (SHELL_HIGH - SHELL_LOW)
    }

    var body: some View {
        DotMatrixTriangleBase(props: props) { row, col, now, active in
            let phase = active ? cyclePhase(now: now, cycleMsBase: 1600, speed: 1, active: true) : 0.2
            return Self.opacityForCell(row, col, phase)
        }
    }
}
