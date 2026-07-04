import SwiftUI

/// Path-wave: snake. Drives `dmx-path` keyframe (=ripple) keyed by snake order.
public struct DotmSquare21: View {
    var props = DotMatrixCommonProps(pattern: .full)
    init(props: DotMatrixCommonProps) { self.props = props }

    /// Source-parity ergonomic init — mirrors `<DotmSquare21 size=… />` upstream. The
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
        PathWaveBase(
            props: props,
            normFn: { idx, _, _ in DotMatrixGridPaths.snakePathNormFromIndex(idx) }
        )
    }
}

/// Shared `path-wave-factory` analogue: `dmx-path` keyframe (= ripple), delay = norm * 0.2333.
struct PathWaveBase: View {
    let props: DotMatrixCommonProps
    let normFn: (Int, Int, Int) -> Double  // (index, row, col) -> norm

    var body: some View {
        DotMatrixBase(props: props, bypassOpacityRemap: true) { ctx, now in
            let baseOp = props.opacityBase ?? DMKeyframes.DEFAULT_BASE
            let peakOp = props.opacityPeak ?? DMKeyframes.DEFAULT_PEAK
            let path = normFn(ctx.index, ctx.row, ctx.col)
            if ctx.reducedMotion || ctx.phase == .idle {
                return baseOp + path * (peakOp - baseOp)
            }
            let cycleSec = 1.5
            let delay = path * 0.2333 * cycleSec
            let t = DMKeyframes.phaseWithDelay(now: now, cycleSec: cycleSec, delaySec: delay)
            return DMKeyframes.ripple(t, base: baseOp, peak: peakOp)
        }
    }
}
