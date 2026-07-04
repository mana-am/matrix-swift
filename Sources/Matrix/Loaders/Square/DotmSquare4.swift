import SwiftUI

/// Dual-ring: outer ring CW + middle ring CCW — `dmx-outer-snake` + `dmx-middle-snake`.
public struct DotmSquare4: View {
    var props = DotMatrixCommonProps(pattern: .full)
    init(props: DotMatrixCommonProps) { self.props = props }

    /// Source-parity ergonomic init — mirrors `<DotmSquare4 size=… />` upstream. The
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

            let isCenter = ctx.row == 2 && ctx.col == 2
            if isCenter { return 0.0 }

            let outerOrder = DotMatrixGridPaths.outerRingClockwiseOrderValue(ctx.index)
            if outerOrder >= 0 {
                let outerNorm = DotMatrixGridPaths.outerRingClockwiseNormFromIndex(ctx.index)
                if ctx.reducedMotion || ctx.phase == .idle {
                    return baseOp + outerNorm * (peakOp - baseOp)
                }
                let cycleSec = 1.5
                let delay = Double(outerOrder) * 0.0625 * cycleSec
                let t = DMKeyframes.phaseWithDelay(now: now, cycleSec: cycleSec, delaySec: delay)
                return DMKeyframes.ringSnake(t, base: baseOp, mid: midOp, peak: peakOp)
            }

            let middleOrder = DotMatrixGridPaths.middleRingAntiClockwiseOrderValue(ctx.index)
            let middleNorm = DotMatrixGridPaths.middleRingAntiClockwiseNormFromIndex(ctx.index)
            if ctx.reducedMotion || ctx.phase == .idle {
                return baseOp + middleNorm * (peakOp - baseOp)
            }
            let cycleSec = 1.5
            let delay = Double(middleOrder) * 0.125 * cycleSec
            let t = DMKeyframes.phaseWithDelay(now: now, cycleSec: cycleSec, delaySec: delay)
            return DMKeyframes.ringSnake(t, base: baseOp, mid: midOp, peak: peakOp)
        }
    }
}
