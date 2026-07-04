import SwiftUI

/// Heart silhouette pulsing on a slowed lub-dub heartbeat (~50 BPM @ cycleSec 1.2).
/// All active cells beat in sync — feels organic, "alive AI".
public struct DotmFunHeart: View {
    var props = DotMatrixCommonProps(pattern: .heart)
    init(props: DotMatrixCommonProps) { self.props = props }

    /// Source-parity ergonomic init — mirrors `<DotmFunHeart size=… />` upstream. The
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
            if ctx.reducedMotion || ctx.phase == .idle {
                return midOp
            }
            let cycleSec = 1.2
            let t = DMKeyframes.phaseWithDelay(now: now, cycleSec: cycleSec, delaySec: 0)
            return DMKeyframes.heartbeat(t, base: baseOp, mid: midOp, peak: peakOp)
        }
    }
}
