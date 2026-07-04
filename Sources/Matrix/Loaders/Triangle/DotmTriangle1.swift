import SwiftUI

/// Triangle 1 — a head chases the triangle perimeter with a 5-level fading tail
/// while the apex-center holds a soft glow. Stepped cycle (30 steps, 1650ms).
/// Mirrors `dotm-triangle-1.tsx`.
struct DotmTriangle1: View {
    var props = DotMatrixCommonProps(size: 30, dotSize: 4, pattern: .full)

    private static let STEP_COUNT = 30
    private static let BASE_OPACITY = 0.08
    private static let CENTER_OPACITY = 0.24
    private static let TAIL_LEVELS: [Double] = [0.96, 0.72, 0.52, 0.34, 0.2]
    private static let PERIMETER: [(Int, Int)] = [
        (1, 3), (2, 2), (3, 1), (4, 0), (4, 2), (4, 4), (4, 6), (3, 5), (2, 4),
    ]

    var body: some View {
        DotMatrixTriangleBase(props: props) { row, col, now, active in
            let frame = steppedCycle(
                now: now, cycleMsBase: 1650, steps: Self.STEP_COUNT, speed: 1, active: active)
            var opacity = Self.BASE_OPACITY
            if row == 3 && col == 3 { opacity = Self.CENTER_OPACITY }
            let head = Int(floor((Double(frame) / Double(Self.STEP_COUNT)) * Double(Self.PERIMETER.count)))
                % Self.PERIMETER.count
            for trail in 0..<Self.TAIL_LEVELS.count {
                let idx = (head - trail + Self.PERIMETER.count) % Self.PERIMETER.count
                let p = Self.PERIMETER[idx]
                if row == p.0 && col == p.1 {
                    opacity = max(opacity, Self.TAIL_LEVELS[trail])
                    break
                }
            }
            return opacity
        }
    }
}
