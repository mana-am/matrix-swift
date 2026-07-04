import SwiftUI

/// Diagonal snake — `dmx-diagonal-snake` keyframe with delay = order * 0.04.
public struct DotmSquare5: View {
    var props = DotMatrixCommonProps(pattern: .full)
    init(props: DotMatrixCommonProps) { self.props = props }

    /// Source-parity ergonomic init — mirrors `<DotmSquare5 size=… />` upstream. The
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
            let order = DotMatrixGridPaths.diagonalSnakeOrderValue(ctx.index)
            let norm = DotMatrixGridPaths.diagonalSnakeNormFromIndex(ctx.index)
            if ctx.reducedMotion || ctx.phase == .idle {
                return baseOp + norm * (peakOp - baseOp)
            }
            let cycleSec = 1.5
            let delay = Double(order) * 0.04 * cycleSec
            let t = DMKeyframes.phaseWithDelay(now: now, cycleSec: cycleSec, delaySec: delay)
            return DMKeyframes.diagonalSnake(t, base: baseOp, mid: midOp, peak: peakOp)
        }
    }
}
