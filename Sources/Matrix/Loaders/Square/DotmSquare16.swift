import SwiftUI

/// Helix variant — tighter center-band (3-column footprint), 1400ms.
struct DotmSquare16: View {
    var props = DotMatrixCommonProps(pattern: .full)

    private static let BASE: Double = 0.08
    private static let STRAND: Double = 1
    private static let BRIDGE: Double = 0.58
    private static let NEAR_STRAND: Double = 0.24
    private static let STEP_COUNT: Double = 20
    private static let HELIX_LOOP_RADIANS: Double = (.pi * 2) / (STEP_COUNT - 1)

    var body: some View {
        DotMatrixBase(props: props) { ctx, now in
            let u: Double = (ctx.reducedMotion || ctx.phase == .idle) ? 0
                : cyclePhase(now: now, cycleMsBase: 1400, speed: 1, active: true)
            let t = u * Self.STEP_COUNT
            let rowPhase = t * Self.HELIX_LOOP_RADIANS + Double(ctx.row) * 1.24
            let left = Int((1.5 + 0.5 * sin(rowPhase)).rounded())
            let right = 4 - left
            let bridgeOn = cos(rowPhase * 2) > 0.82
            if ctx.col == left || ctx.col == right { return Self.STRAND }
            if bridgeOn && ctx.col > left && ctx.col < right { return Self.BRIDGE }
            if abs(ctx.col - left) == 1 || abs(ctx.col - right) == 1 { return Self.NEAR_STRAND }
            return Self.BASE
        }
    }
}
