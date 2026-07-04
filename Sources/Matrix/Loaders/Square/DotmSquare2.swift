import SwiftUI

/// Boustrophedon snake with 8-level tail — JS-step, steppedCycle.
struct DotmSquare2: View {
    var props = DotMatrixCommonProps(pattern: .full)

    private static let SNAKE_TAIL: [Double] = [1, 0.82, 0.68, 0.54, 0.42, 0.31, 0.22, 0.14]
    private static let BASE_OPACITY: Double = 0.08

    /// Mirrors `buildRowCyclePath()` from the .tsx exactly. Length = 41.
    private static let ROUTE: [Int] = {
        var path: [Int] = []
        // 1st col: bottom -> top
        for row in stride(from: 4, through: 0, by: -1) { path.append(rowMajorIndex(row, 0)) }
        // top to 3rd col
        path.append(rowMajorIndex(0, 1))
        path.append(rowMajorIndex(0, 2))
        // 3rd col: top -> bottom
        for row in 1...4 { path.append(rowMajorIndex(row, 2)) }
        // bottom left to 2nd col
        path.append(rowMajorIndex(4, 1))
        // 2nd col: bottom -> top
        for row in stride(from: 3, through: 0, by: -1) { path.append(rowMajorIndex(row, 1)) }
        // top right to 4th col
        path.append(rowMajorIndex(0, 2))
        path.append(rowMajorIndex(0, 3))
        // 4th col: top -> bottom
        for row in 1...4 { path.append(rowMajorIndex(row, 3)) }
        // bottom left to 3rd col
        path.append(rowMajorIndex(4, 2))
        // 3rd col: bottom -> top
        for row in stride(from: 3, through: 0, by: -1) { path.append(rowMajorIndex(row, 2)) }
        // top right to 5th col
        path.append(rowMajorIndex(0, 3))
        path.append(rowMajorIndex(0, 4))
        // 5th col: top -> bottom
        for row in 1...4 { path.append(rowMajorIndex(row, 4)) }
        return path
    }()

    /// For each cell index, all steps at which it appears in ROUTE.
    private static let VISITS_BY_INDEX: [[Int]] = {
        var visits = Array(repeating: [Int](), count: MATRIX_CELLS)
        for (step, idx) in ROUTE.enumerated() { visits[idx].append(step) }
        return visits
    }()

    var body: some View {
        let routeLen = Self.ROUTE.count
        DotMatrixBase(props: props) { ctx, now in
            // When idle, steppedCycle returns idleStep=0 (matches JS useSteppedCycle behavior).
            let head = steppedCycle(
                now: now, cycleMsBase: 1500, steps: routeLen, speed: 1,
                active: !ctx.reducedMotion && ctx.phase != .idle)
            let visits = Self.VISITS_BY_INDEX[ctx.index]
            var opacity = Self.BASE_OPACITY
            for stepIndex in visits {
                let distance = (head - stepIndex + routeLen) % routeLen
                if distance >= 0 && distance < Self.SNAKE_TAIL.count {
                    opacity = max(opacity, Self.SNAKE_TAIL[distance])
                }
            }
            return opacity
        }
    }
}
