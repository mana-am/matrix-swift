import SwiftUI

/// Triangle 17 — a soft head traces an "∞": up the left rim to the apex, down the
/// right rim, then cuts through (4,4)→center→(4,2). Cycle (1500ms).
/// Mirrors `dotm-triangle-17.tsx`.
struct DotmTriangle17: View {
    var props = DotMatrixCommonProps(size: 30, dotSize: 4, pattern: .full)

    private static let BASE_OPACITY = 0.06
    private static let HIGH_OPACITY = 0.95
    private static let TRAIL_SPAN = 4.35
    private static let PATH: [(Int, Int)] = [
        (4, 0), (3, 1), (2, 2), (1, 3), (2, 4), (3, 5), (4, 6), (4, 4), (3, 3), (4, 2),
    ]

    private static func pathIndex(_ row: Int, _ col: Int) -> Int? {
        for (i, p) in PATH.enumerated() where p.0 == row && p.1 == col { return i }
        return nil
    }

    private static func opacityForCell(_ row: Int, _ col: Int, _ phase: Double) -> Double {
        guard let idx = pathIndex(row, col) else { return 0 }
        let pathLen = Double(PATH.count)
        let s = phase * pathLen
        let d = dmHexModF(s - Double(idx), pathLen)
        let g = 1 - dmHexSmoothstep01(0, TRAIL_SPAN, d)
        return BASE_OPACITY + g * (HIGH_OPACITY - BASE_OPACITY)
    }

    var body: some View {
        DotMatrixTriangleBase(props: props) { row, col, now, active in
            let phase = active ? cyclePhase(now: now, cycleMsBase: 1500, speed: 1, active: true) : 0.12
            return Self.opacityForCell(row, col, phase)
        }
    }
}
