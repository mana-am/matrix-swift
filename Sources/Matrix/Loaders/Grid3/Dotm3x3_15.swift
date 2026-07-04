import SwiftUI

/// 3×3 ripple echo — manhattan rings pulse with a parity-offset echo;
/// `dmx-ripple-echo` keyframe, per-dot delay = (ring ×0.1 + parity ×0.02) ×cycle
/// (`dmx-ripple-echo-3`, dur ×1.06). Mirrors `dotm-3x3-15.tsx` (speed 1.75).
public struct Dotm3x3_15: View {
    var props = DotMatrixCommonProps(speed: 1.75, pattern: .full)
    init(props: DotMatrixCommonProps) { self.props = props }

    /// Source-parity ergonomic init — mirrors `<Dotm3x3_15 size=… />` upstream. The
    /// loader's shape/pattern is fixed; you size and color it.
    public init(
        size: CGFloat = 24,
        color: Color = .primary,
        speed: Double = 1,
        dotSize: CGFloat? = nil,
        muted: Bool = false,
        bloom: Bool = false,
        halo: Double = 0
    ) {
        props.size = size
        props.color = color
        props.speed = speed
        props.dotSize = dotSize ?? max(2, floor(size / 6))
        props.muted = muted
        props.bloom = bloom
        props.halo = halo
    }

    public var body: some View {
        DotMatrix3Base(props: props, bypassOpacityRemap: true) { ctx, now in
            let t3 = dm3UserTriplet(props)
            let ring = max(0, min(2, ctx.manhattanDistance))
            let parity = ring % 2
            if ctx.reducedMotion || ctx.phase == .idle {
                return remapOpacityToTriplet(
                    0.06 + (1 - Double(ring) / 2) * 0.82,
                    base: props.opacityBase ?? 0.06, mid: props.opacityMid, peak: props.opacityPeak)
            }
            let cycleSec = DM3Keyframes.CYCLE_SEC * 1.06
            let delay = (Double(ring) * 0.1 + Double(parity) * 0.02) * DM3Keyframes.CYCLE_SEC
            let t = DMKeyframes.phaseWithDelay(now: now, cycleSec: cycleSec, delaySec: delay)
            return DMKeyframes.rippleEcho(t, base: t3.base, mid: t3.mid, peak: t3.peak)
        }
    }
}
