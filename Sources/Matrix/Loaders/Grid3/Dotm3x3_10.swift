import SwiftUI

/// 3×3 frame chase — a head chases the outer ring clockwise while the center
/// core pulses. Ring dots run `dmx-ripple-3` (`dmx-frame-chase-3`, dur ×0.98,
/// delay = ringOrder ×0.09 ×cycle); the center runs `dmx-ripple-3`
/// (`dmx-core-pulse-3`, dur ×0.46, no delay). Mirrors `dotm-3x3-10.tsx`.
struct Dotm3x3_10: View {
    var props = DotMatrixCommonProps(speed: 1.75, pattern: .full)
    var body: some View {
        DotMatrix3Base(props: props, bypassOpacityRemap: true) { ctx, now in
            let t3 = dm3UserTriplet(props)

            if DotMatrix3GridPaths.isCenterCell(row: ctx.row, col: ctx.col) {
                if ctx.reducedMotion || ctx.phase == .idle {
                    return remapOpacityToTriplet(
                        0.2, base: props.opacityBase ?? 0.06,
                        mid: props.opacityMid, peak: props.opacityPeak)
                }
                let cycleSec = DM3Keyframes.CYCLE_SEC * 0.46
                let t = DMKeyframes.phaseWithDelay(now: now, cycleSec: cycleSec, delaySec: 0)
                return DM3Keyframes.ripple3(t, base: t3.base, mid: t3.mid, peak: t3.peak)
            }

            let order = DotMatrix3GridPaths.outerRingClockwiseOrderValue(ctx.index)
            let path = DotMatrix3GridPaths.outerRingClockwiseNorm(ctx.index)
            if ctx.reducedMotion || ctx.phase == .idle {
                return remapOpacityToTriplet(
                    DotMatrix3GridPaths.pathOpacityFromNorm(path),
                    base: props.opacityBase ?? 0.06, mid: props.opacityMid, peak: props.opacityPeak)
            }
            let cycleSec = DM3Keyframes.CYCLE_SEC * 0.98
            let delay = Double(order) * 0.09 * DM3Keyframes.CYCLE_SEC
            let t = DMKeyframes.phaseWithDelay(now: now, cycleSec: cycleSec, delaySec: delay)
            return DM3Keyframes.ripple3(t, base: t3.base, mid: t3.mid, peak: t3.peak)
        }
    }
}
