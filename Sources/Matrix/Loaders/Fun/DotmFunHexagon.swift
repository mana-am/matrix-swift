import SwiftUI

/// Hexagon outline rotating clockwise — each border cell fires in CW order via the
/// outerRingClockwise path, with mid-row cells (left/right) bridging the loop.
public struct DotmFunHexagon: View {
    var props = DotMatrixCommonProps(pattern: .hexagon)
    init(props: DotMatrixCommonProps) { self.props = props }

    /// Source-parity ergonomic init — mirrors `<DotmFunHexagon size=… />` upstream. The
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


    /// Manually-ordered traversal of the hexagon perimeter clockwise from top-left.
    private static let CW_ORDER: [Int] = [
        1, 2, 3,        // top edge L→R
        9, 14, 19,      // right side T→B
        23, 22, 21,     // bottom edge R→L
        15, 10, 5,      // left side B→T
    ]

    public var body: some View {
        DotMatrixBase(props: props, bypassOpacityRemap: true) { ctx, now in
            let baseOp = props.opacityBase ?? DMKeyframes.DEFAULT_BASE
            let midOp = props.opacityMid ?? DMKeyframes.DEFAULT_MID
            let peakOp = props.opacityPeak ?? DMKeyframes.DEFAULT_PEAK
            let order = Self.CW_ORDER.firstIndex(of: ctx.index) ?? 0
            let norm = Double(order) / Double(Self.CW_ORDER.count - 1)
            if ctx.reducedMotion || ctx.phase == .idle {
                return baseOp + norm * (peakOp - baseOp)
            }
            let cycleSec = 1.5
            let delay = norm * 0.85 * cycleSec
            let t = DMKeyframes.phaseWithDelay(now: now, cycleSec: cycleSec, delaySec: delay)
            return DMKeyframes.ringSnake(t, base: baseOp, mid: midOp, peak: peakOp)
        }
    }
}
