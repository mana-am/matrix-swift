import SwiftUI

/// Helix on circle-mask grid.
struct DotmCircular1: View {
    var props = DotMatrixCommonProps(pattern: .full)
    private static let BASE: Double = 0.08
    private static let STRAND: Double = 1
    private static let NEAR: Double = 0.24
    private static let STEP_COUNT: Double = 20
    private static let HELIX_LOOP_RADIANS: Double = (.pi * 2) / (STEP_COUNT - 1)

    var body: some View {
        DotMatrixBase(props: props) { ctx, now in
            if !isWithinCircularMask(row: ctx.row, col: ctx.col) { return 0 }
            let u: Double = (ctx.reducedMotion || ctx.phase == .idle) ? 0
                : cyclePhase(now: now, cycleMsBase: 1700, speed: 1, active: true)
            let t = u * Self.STEP_COUNT
            let diagonalAxis = Double(ctx.row + ctx.col)
            let phaseOffset = t * Self.HELIX_LOOP_RADIANS + diagonalAxis * 0.82
            let strandPerp = Int((2 * sin(phaseOffset)).rounded())
            let cellPerp = ctx.col - ctx.row
            let dist = abs(cellPerp - strandPerp)
            if dist == 0 { return Self.STRAND }
            if dist == 1 { return Self.NEAR }
            return Self.BASE
        }
    }
}
