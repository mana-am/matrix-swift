import SwiftUI

/// 3×3 spiral-snake — head sweeps the inward spiral order; `dmx-spiral-snake`
/// keyframe with per-dot delay = spiralOrder ×0.038 ×cycle (`dmx-spiral-snake-3`,
/// dur ×0.78). Mirrors `dotm-3x3-1.tsx`.
struct Dotm3x3_1: View {
    var props = DotMatrixCommonProps(speed: 1.15, pattern: .full)
    var body: some View {
        DotMatrix3Base(props: props, bypassOpacityRemap: true) { ctx, now in
            let t3 = dm3UserTriplet(props)
            let order = DotMatrix3GridPaths.spiralInwardOrderValue(ctx.index)
            let path = DotMatrix3GridPaths.spiralInwardNorm(ctx.index)
            if ctx.reducedMotion || ctx.phase == .idle {
                return remapOpacityToTriplet(
                    DotMatrix3GridPaths.pathOpacityFromNorm(path),
                    base: props.opacityBase ?? 0.06, mid: props.opacityMid, peak: props.opacityPeak)
            }
            let cycleSec = DM3Keyframes.CYCLE_SEC * 0.78
            let delay = Double(order) * 0.038 * DM3Keyframes.CYCLE_SEC
            let t = DMKeyframes.phaseWithDelay(now: now, cycleSec: cycleSec, delaySec: delay)
            return DMKeyframes.spiralSnake(t, base: t3.base, mid: t3.mid, peak: t3.peak)
        }
    }
}
