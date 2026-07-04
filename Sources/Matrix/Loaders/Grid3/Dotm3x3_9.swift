import SwiftUI

/// 3×3 snake path — boustrophedon sweep; `dmx-ripple-3` keyframe, per-dot delay =
/// snakeOrder ×0.085 ×cycle (`dmx-snake-path-3`, dur ×1.04). Mirrors `dotm-3x3-9.tsx`.
struct Dotm3x3_9: View {
    var props = DotMatrixCommonProps(speed: 1.75, pattern: .full)
    var body: some View {
        DotMatrix3Base(props: props, bypassOpacityRemap: true) { ctx, now in
            let t3 = dm3UserTriplet(props)
            let order = DotMatrix3GridPaths.snakeOrderValue(ctx.index)
            let path = DotMatrix3GridPaths.snakeNorm(ctx.index)
            if ctx.reducedMotion || ctx.phase == .idle {
                return remapOpacityToTriplet(
                    DotMatrix3GridPaths.pathOpacityFromNorm(path),
                    base: props.opacityBase ?? 0.06, mid: props.opacityMid, peak: props.opacityPeak)
            }
            let cycleSec = DM3Keyframes.CYCLE_SEC * 1.04
            let delay = Double(order) * 0.085 * DM3Keyframes.CYCLE_SEC
            let t = DMKeyframes.phaseWithDelay(now: now, cycleSec: cycleSec, delaySec: delay)
            return DM3Keyframes.ripple3(t, base: t3.base, mid: t3.mid, peak: t3.peak)
        }
    }
}
