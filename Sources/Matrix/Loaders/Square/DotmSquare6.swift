import SwiftUI

/// Column snake — `dmx-square6-col-snake` keyframe. Columns alternate up/down.
public struct DotmSquare6: View {
    var props = DotMatrixCommonProps(pattern: .full)
    init(props: DotMatrixCommonProps) { self.props = props }

    /// Source-parity ergonomic init — mirrors `<DotmSquare6 size=… />` upstream. The
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


    private static let COLUMN_HEIGHT = 5

    public var body: some View {
        DotMatrixBase(props: props, bypassOpacityRemap: true) { ctx, now in
            let baseOp = props.opacityBase ?? DMKeyframes.DEFAULT_BASE
            let midOp = props.opacityMid ?? DMKeyframes.DEFAULT_MID
            let peakOp = props.opacityPeak ?? DMKeyframes.DEFAULT_PEAK
            let goesUp = ctx.col % 2 == 0
            let position = goesUp ? (Self.COLUMN_HEIGHT - 1 - ctx.row) : ctx.row
            if ctx.reducedMotion || ctx.phase == .idle {
                let norm = Double(position) / Double(Self.COLUMN_HEIGHT - 1)
                return baseOp + norm * (peakOp - baseOp) * 0.85
            }
            let cycleSec = 1.5
            let delay = Double(position) * 0.2 * cycleSec
            let t = DMKeyframes.phaseWithDelay(now: now, cycleSec: cycleSec, delaySec: delay)
            return DMKeyframes.square6ColSnake(t, base: baseOp, mid: midOp, peak: peakOp)
        }
    }
}
