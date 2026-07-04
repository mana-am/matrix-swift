import SwiftUI

/// Swing rung — active row sweeps with swinging anchors.
public struct DotmCircular14: View {
    var props = DotMatrixCommonProps(pattern: .full)
    init(props: DotMatrixCommonProps) { self.props = props }

    /// Source-parity ergonomic init — mirrors `<DotmCircular14 size=… />` upstream. The
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

    private static let BASE_OPACITY: Double = 0.07
    private static let RUNG_OPACITY: Double = 0.95
    private static let SIDE_OPACITY: Double = 0.56
    private static let GHOST_OPACITY: Double = 0.28

    public var body: some View {
        DotMatrixBase(props: props) { ctx, now in
            guard isWithinCircularMask(row: ctx.row, col: ctx.col) else { return 0 }

            let x = ctx.col - 2
            let y = ctx.row - 2
            let animPhase = cyclePhase(now: now, cycleMsBase: 1650, speed: 1,
                                       active: !ctx.reducedMotion && ctx.phase != .idle)
            let phaseStep = ctx.reducedMotion || ctx.phase == .idle
                ? 0
                : Int(floor(animPhase * 10))
            let activeRow = (phaseStep + 5) % 5
            let rowDistance = abs(ctx.row - activeRow)
            let swingAngle = Double(phaseStep) / 10.0 * .pi * 2 + Double(y) * 0.9
            let swing = sin(swingAngle)
            let leftAnchor = Int((1.0 + swing).rounded())
            let rightAnchor = 4 - leftAnchor

            var opacity = Self.BASE_OPACITY
            if ctx.row == activeRow && ctx.col >= leftAnchor && ctx.col <= rightAnchor {
                opacity = Self.RUNG_OPACITY
            } else if (ctx.col == leftAnchor || ctx.col == rightAnchor) && rowDistance <= 1 {
                opacity = Self.SIDE_OPACITY
            } else if (ctx.col == leftAnchor || ctx.col == rightAnchor) && rowDistance == 2 {
                opacity = Self.GHOST_OPACITY
            }

            if x == 0 && y == 0 && rowDistance <= 1 {
                return max(opacity, Self.SIDE_OPACITY)
            }
            return opacity
        }
    }
}
