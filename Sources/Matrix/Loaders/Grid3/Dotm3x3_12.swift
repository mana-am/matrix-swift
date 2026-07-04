import SwiftUI

/// 3×3 distance ripple — Euclidean rings pulse outward; `dmx-ripple-3` keyframe
/// with `ease-out` timing and per-dot delay = distance ×0.13 ×cycle
/// (`dmx-distance-ripple-3`, dur ×1.3). Mirrors `dotm-3x3-12.tsx` (speed 1.75).
struct Dotm3x3_12: View {
    var props = DotMatrixCommonProps(speed: 1.75, pattern: .full)
    var body: some View {
        DotMatrix3Base(props: props, bypassOpacityRemap: true) { ctx, now in
            let t3 = dm3UserTriplet(props)
            let ring = max(0, min(2, Int(ctx.distanceFromCenter.rounded())))
            if ctx.reducedMotion || ctx.phase == .idle {
                return remapOpacityToTriplet(
                    0.06 + (1 - Double(ring) / 2) * 0.82,
                    base: props.opacityBase ?? 0.06, mid: props.opacityMid, peak: props.opacityPeak)
            }
            let cycleSec = DM3Keyframes.CYCLE_SEC * 1.3
            let delay = ctx.distanceFromCenter * 0.13 * DM3Keyframes.CYCLE_SEC
            let t = DMKeyframes.phaseWithDelay(now: now, cycleSec: cycleSec, delaySec: delay)
            return DM3Keyframes.ripple3(t, base: t3.base, mid: t3.mid, peak: t3.peak, easeOut: true)
        }
    }
}
