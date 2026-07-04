import SwiftUI

/// 6 glyph cycle with ghost trail.
struct DotmCircular20: View {
    var props = DotMatrixCommonProps(pattern: .full)
    private static let BASE_OPACITY: Double = 0.07
    private static let MID_OPACITY: Double = 0.34
    private static let HIGH_OPACITY: Double = 0.95

    private static let GLYPHS: [Set<String>] = [
        ["1,1", "2,1", "3,1", "1,3", "2,3", "3,3"],
        ["1,1", "2,1", "3,1", "2,2", "1,3", "3,3"],
        ["1,1", "1,2", "1,3", "3,1", "3,2", "3,3"],
        ["1,1", "2,1", "3,1", "1,3", "2,2", "3,3"],
        ["1,1", "2,2", "3,3", "1,3", "3,1"],
        ["2,1", "1,2", "2,2", "3,2", "2,3"],
    ]

    var body: some View {
        DotMatrixBase(props: props) { ctx, now in
            guard isWithinCircularMask(row: ctx.row, col: ctx.col) else { return 0 }

            let animPhase = cyclePhase(now: now, cycleMsBase: 1500, speed: 1,
                                       active: !ctx.reducedMotion && ctx.phase != .idle)
            let n = Self.GLYPHS.count
            // When idle/reducedMotion t=0 → shows GLYPHS[0] as active, GLYPHS[5] as previous
            let t = ctx.reducedMotion || ctx.phase == .idle
                ? 0
                : Int(floor(animPhase * Double(n))) % n
            let active = Self.GLYPHS[t]
            let previous = Self.GLYPHS[(t + n - 1) % n]
            let key = "\(ctx.row),\(ctx.col)"

            var opacity = Self.BASE_OPACITY
            if active.contains(key) {
                opacity = Self.HIGH_OPACITY
            } else if previous.contains(key) {
                opacity = Self.MID_OPACITY
            } else if ctx.row == 2 && ctx.col == 2 {
                opacity = 0.2
            }

            return opacity
        }
    }
}
