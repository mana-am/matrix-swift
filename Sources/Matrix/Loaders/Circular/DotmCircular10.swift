import SwiftUI

/// Modulo cell-code chase + parity gate.
struct DotmCircular10: View {
    var props = DotMatrixCommonProps(pattern: .full)
    private static let BASE: Double = 0.06
    private static let LOW: Double = 0.2
    private static let MID: Double = 0.48
    private static let HIGH: Double = 0.94

    var body: some View {
        DotMatrixBase(props: props) { ctx, now in
            if !isWithinCircularMask(row: ctx.row, col: ctx.col) { return 0 }
            let phase = cyclePhase(now: now, cycleMsBase: 1600, speed: 1,
                                   active: !ctx.reducedMotion && ctx.phase != .idle)
            let x = ctx.col - 2
            let y = ctx.row - 2
            let ring = Int(sqrt(Double(x * x + y * y)).rounded())
            let tick = Int(floor(phase * 10))
            let cellCode = (ctx.row * 3 + ctx.col * 5 + ring * 2) % 10
            let raw = abs(cellCode - tick)
            let d = min(raw, 10 - raw)
            let parityGate = (ctx.row + ctx.col + tick) % 2 == 0
            var opacity = Self.BASE
            if d == 0 { opacity = Self.HIGH }
            else if d == 1 { opacity = Self.MID }
            else if d == 2 || parityGate { opacity = Self.LOW }
            if x == 0 && y == 0 { return max(opacity, Self.MID) }
            return opacity
        }
    }
}
