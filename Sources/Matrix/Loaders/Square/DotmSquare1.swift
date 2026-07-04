import SwiftUI

/// Diagonal alt sweep — `dmx-diagonal-alt-sweep` keyframe with delay = path*0.2 + parity*0.5.
public struct DotmSquare1: View {
    var props = DotMatrixCommonProps(pattern: .full)
    init(props: DotMatrixCommonProps) { self.props = props }

    /// Source-parity ergonomic init — mirrors `<DotmSquare1 size=… />` upstream. The
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
            let path = DotMatrixGridPaths.trBlPathNormFromIndex(ctx.index)
            let slice = ctx.row + (4 - ctx.col)
            let parity = Double(slice % 2)
            if ctx.reducedMotion || ctx.phase == .idle {
                return parity == 0 ? peakOp : baseOp * 0.875
            }
            let cycleSec = 1.5
            let delay = (path * 0.2 + parity * 0.5) * cycleSec
            let t = DMKeyframes.phaseWithDelay(now: now, cycleSec: cycleSec, delaySec: delay)
            return DMKeyframes.diagonalAltSweep(t, base: baseOp, peak: peakOp)
        }
    }
}
