import SwiftUI

/// Comet pair on the 12-cell ring, half-loop apart.
struct DotmCircular3: View {
    var props = DotMatrixCommonProps(pattern: .full)

    private static let STEP_COUNT: Int = 24
    private static let BASE_OPACITY: Double = 0.08
    private static let RING_BASE_OPACITY: Double = 0.2
    private static let CORE_OPACITY: Double = 0.16
    private static let COMET_TAIL: [Double] = [1, 0.78, 0.56, 0.36, 0.22]
    private static let SECONDARY_COMET_SCALE: Double = 0.72

    // row-major indices for the 12-cell ring
    private static let CIRCULAR_RING_PATH: [Int] = [
        0 * 5 + 1,  // (0,1)
        0 * 5 + 2,  // (0,2)
        0 * 5 + 3,  // (0,3)
        1 * 5 + 4,  // (1,4)
        2 * 5 + 4,  // (2,4)
        3 * 5 + 4,  // (3,4)
        4 * 5 + 3,  // (4,3)
        4 * 5 + 2,  // (4,2)
        4 * 5 + 1,  // (4,1)
        3 * 5 + 0,  // (3,0)
        2 * 5 + 0,  // (2,0)
        1 * 5 + 0,  // (1,0)
    ]
    private static let LOOP_LEN: Int = 12

    var body: some View {
        DotMatrixBase(props: props) { ctx, now in
            guard isWithinCircularMask(row: ctx.row, col: ctx.col) else { return 0 }

            let index = ctx.row * 5 + ctx.col
            let isCore = ctx.row == 2 && ctx.col == 2

            guard let pathOrder = Self.CIRCULAR_RING_PATH.firstIndex(of: index) else {
                return isCore ? Self.CORE_OPACITY : Self.BASE_OPACITY
            }

            if ctx.reducedMotion || ctx.phase == .idle {
                return Self.RING_BASE_OPACITY + (Double(pathOrder) / Double(Self.LOOP_LEN - 1)) * 0.56
            }

            let headStep = steppedCycle(
                now: now, cycleMsBase: 1650, steps: Self.STEP_COUNT, speed: 1, active: true)
            let leadA = (headStep * Self.LOOP_LEN / Self.STEP_COUNT) % Self.LOOP_LEN
            let leadB = (leadA + Self.LOOP_LEN / 2) % Self.LOOP_LEN

            var opacity = Self.BASE_OPACITY
            for i in 0 ..< Self.COMET_TAIL.count {
                let weight = Self.COMET_TAIL[i]
                let tailA = (leadA - i + Self.LOOP_LEN) % Self.LOOP_LEN
                let tailB = (leadB - i + Self.LOOP_LEN) % Self.LOOP_LEN
                if pathOrder == tailA {
                    opacity = max(opacity, weight)
                }
                if pathOrder == tailB {
                    opacity = max(opacity, weight * Self.SECONDARY_COMET_SCALE)
                }
            }

            return min(1, opacity)
        }
    }
}
