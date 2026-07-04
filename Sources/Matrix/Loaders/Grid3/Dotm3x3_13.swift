import SwiftUI

/// 3×3 column wave, reversed (right → left); `dmx-ripple-3` keyframe, per-dot
/// delay = colPathReverse ×0.19 ×cycle (`dmx-path-3`, dur ×0.68).
/// Mirrors `dotm-3x3-13.tsx` (speed 1.75).
struct Dotm3x3_13: View {
    var props = DotMatrixCommonProps(speed: 1.75, pattern: .full)
    var body: some View {
        DotMatrix3Base(props: props, bypassOpacityRemap: true) { ctx, now in
            let t3 = dm3UserTriplet(props)
            let path = DotMatrix3GridPaths.colWaveNormReverse(ctx.col)
            if ctx.reducedMotion || ctx.phase == .idle {
                return remapOpacityToTriplet(
                    DotMatrix3GridPaths.pathOpacityFromNorm(path),
                    base: props.opacityBase ?? 0.06, mid: props.opacityMid, peak: props.opacityPeak)
            }
            let cycleSec = DM3Keyframes.CYCLE_SEC * 0.68
            let delay = path * 0.19 * DM3Keyframes.CYCLE_SEC
            let t = DMKeyframes.phaseWithDelay(now: now, cycleSec: cycleSec, delaySec: delay)
            return DM3Keyframes.ripple3(t, base: t3.base, mid: t3.mid, peak: t3.peak)
        }
    }
}
