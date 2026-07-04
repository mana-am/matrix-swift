import SwiftUI

/// One cell pops first, then neighbors fire with delay proportional to Manhattan distance,
/// like confetti expanding from an explosion. The "center" cycles through 4 corners over
/// time so each cycle looks different.
struct DotmFunConfetti: View {
    var props = DotMatrixCommonProps(pattern: .full)

    /// Four origin points the confetti rotates through.
    private static let ORIGINS: [(Int, Int)] = [(0, 0), (0, 4), (4, 4), (4, 0)]
    private static let CYCLE_SEC: Double = 1.6

    var body: some View {
        DotMatrixBase(props: props, bypassOpacityRemap: true) { ctx, now in
            let baseOp = props.opacityBase ?? DMKeyframes.DEFAULT_BASE
            let midOp = props.opacityMid ?? DMKeyframes.DEFAULT_MID
            let peakOp = props.opacityPeak ?? DMKeyframes.DEFAULT_PEAK
            // Which origin we're currently on (changes every cycle).
            let cycleCount = floor(now / Self.CYCLE_SEC)
            let originIdx = Int(cycleCount.truncatingRemainder(dividingBy: Double(Self.ORIGINS.count)))
            let safeIdx = (originIdx % Self.ORIGINS.count + Self.ORIGINS.count) % Self.ORIGINS.count
            let (or, oc) = Self.ORIGINS[safeIdx]
            let dist = abs(ctx.row - or) + abs(ctx.col - oc)
            if ctx.reducedMotion || ctx.phase == .idle {
                let norm = 1 - Double(dist) / 8.0
                return baseOp + norm * (peakOp - baseOp) * 0.5
            }
            let delay = Double(dist) * 0.07 * Self.CYCLE_SEC
            let t = DMKeyframes.phaseWithDelay(now: now, cycleSec: Self.CYCLE_SEC, delaySec: delay)
            return DMKeyframes.confettiPop(t, base: baseOp, mid: midOp, peak: peakOp)
        }
    }
}
