import SwiftUI

/// Pulse from center, ring fade — center pulses first, each Manhattan-ring lights up
/// progressively later and decays at its own rate. Distinct from `centerOriginRipple`
/// (which loops every cell on the same envelope) because each ring has independent
/// linger and decay.
public struct DotmFunPulseRing: View {
    var props = DotMatrixCommonProps(pattern: .full)
    init(props: DotMatrixCommonProps) { self.props = props }

    /// Source-parity ergonomic init — mirrors `<DotmFunPulseRing size=… />` upstream. The
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
        DotMatrixBase(props: props, bypassOpacityRemap: true) { ctx, now in
            let baseOp = props.opacityBase ?? DMKeyframes.DEFAULT_BASE
            let midOp = props.opacityMid ?? DMKeyframes.DEFAULT_MID
            let peakOp = props.opacityPeak ?? DMKeyframes.DEFAULT_PEAK
            let ring = ctx.manhattanDistance  // 0…4
            if ctx.reducedMotion || ctx.phase == .idle {
                let norm = 1 - Double(ring) / 4.0
                return baseOp + norm * (peakOp - baseOp)
            }
            let cycleSec = 2.0
            let t = DMKeyframes.phaseWithDelay(now: now, cycleSec: cycleSec, delaySec: 0)
            return DMKeyframes.pulseRing(
                t, ring: ring, maxRing: 4,
                base: baseOp, mid: midOp, peak: peakOp
            )
        }
    }
}
