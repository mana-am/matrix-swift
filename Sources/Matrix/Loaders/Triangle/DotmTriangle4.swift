import SwiftUI

/// Triangle 4 — three evenly-spaced heads chase the perimeter, each with a
/// 3-level tail. Stepped cycle (28 steps, 1450ms). Mirrors `dotm-triangle-4.tsx`.
struct DotmTriangle4: View {
    var props = DotMatrixCommonProps(size: 30, dotSize: 4, pattern: .full)

    private static let STEP_COUNT = 28
    private static let BASE_OPACITY = 0.0
    private static let MID_OPACITY = 0.0
    private static let HIGH_OPACITY = 0.96
    private static let TRAIL_LEVELS: [Double] = [0.96, 0.52, 0.3]
    private static let PERIMETER: [(Int, Int)] = [
        (1, 3), (2, 2), (3, 1), (4, 0), (4, 2), (4, 4), (4, 6), (3, 5), (2, 4),
    ]

    var body: some View {
        DotMatrixTriangleBase(props: props) { row, col, now, active in
            let frame = steppedCycle(
                now: now, cycleMsBase: 1450, steps: Self.STEP_COUNT, speed: 1, active: active)
            let segmentLength = max(1, Self.STEP_COUNT / 3)
            var opacity = (row == 3 && col == 3) ? Self.MID_OPACITY : Self.BASE_OPACITY

            for headOffset in 0..<3 {
                let spokeFrame = (frame + headOffset * segmentLength) % Self.STEP_COUNT
                let head = Int(floor((Double(spokeFrame) / Double(Self.STEP_COUNT)) * Double(Self.PERIMETER.count)))
                for trail in 0..<Self.TRAIL_LEVELS.count {
                    let idx = (head - trail + Self.PERIMETER.count) % Self.PERIMETER.count
                    let p = Self.PERIMETER[idx]
                    if row == p.0 && col == p.1 {
                        opacity = max(opacity, Self.TRAIL_LEVELS[trail])
                        break
                    }
                }
            }
            return opacity
        }
    }
}
