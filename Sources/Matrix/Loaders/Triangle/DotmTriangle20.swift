import SwiftUI

/// Triangle 20 — two heads chase the perimeter half a lap apart, each with its own
/// soft tail; the heart stays dim. Cycle (1800ms). Mirrors `dotm-triangle-20.tsx`.
struct DotmTriangle20: View {
    var props = DotMatrixCommonProps(size: 30, dotSize: 4, pattern: .full)

    private static let BASE_OPACITY = 0.08
    private static let HIGH_OPACITY = 0.94
    private static let CENTER_DIM = 0.2
    private static let TRAIL_SPAN = 3.35
    private static let PATH: [(Int, Int)] = [
        (1, 3), (2, 2), (3, 1), (4, 0), (4, 2), (4, 4), (4, 6), (3, 5), (2, 4),
    ]

    private static func pathIndex(_ row: Int, _ col: Int) -> Int? {
        for (i, p) in PATH.enumerated() where p.0 == row && p.1 == col { return i }
        return nil
    }

    private static func glowAlongPath(_ s: Double, _ idx: Int?, _ pathLen: Double) -> Double {
        guard let idx = idx else { return BASE_OPACITY }
        let d = dmHexModF(s - Double(idx), pathLen)
        let g = 1 - dmHexSmoothstep01(0, TRAIL_SPAN, d)
        return BASE_OPACITY + g * (HIGH_OPACITY - BASE_OPACITY)
    }

    private static func opacityForCell(_ row: Int, _ col: Int, _ phase: Double) -> Double {
        if row == 3 && col == 3 { return CENTER_DIM }
        let pathLen = Double(PATH.count)
        let idx = pathIndex(row, col)
        let s1 = phase * pathLen
        let s2 = dmHexModF(s1 + pathLen / 2, pathLen)
        let a = glowAlongPath(s1, idx, pathLen)
        let b = glowAlongPath(s2, idx, pathLen)
        return min(HIGH_OPACITY, max(a, b))
    }

    var body: some View {
        DotMatrixTriangleBase(props: props) { row, col, now, active in
            let phase = active ? cyclePhase(now: now, cycleMsBase: 1800, speed: 1, active: true) : 0.1
            return Self.opacityForCell(row, col, phase)
        }
    }
}
