import SwiftUI

/// Eye silhouette doing slow breathing. Iris pulses 1.3× brighter than outline at peak.
public struct DotmFunEye: View {
    var props = DotMatrixCommonProps(pattern: .eye)
    init(props: DotMatrixCommonProps) { self.props = props }

    /// Source-parity ergonomic init — mirrors `<DotmFunEye size=… />` upstream. The
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
            let peakOp = props.opacityPeak ?? DMKeyframes.DEFAULT_PEAK
            let isIris = ctx.row == 2 && ctx.col == 2
            if ctx.reducedMotion || ctx.phase == .idle {
                return isIris ? peakOp : 0.5 * (baseOp + peakOp)
            }
            let cycleSec = 4.0
            let t = DMKeyframes.phaseWithDelay(now: now, cycleSec: cycleSec, delaySec: 0)
            let breath = DMKeyframes.breathing(t, base: baseOp, peak: peakOp)
            // Iris breathes between mid and a hot peak.
            return isIris ? min(1.0, breath * 1.15 + 0.05) : breath
        }
    }
}
