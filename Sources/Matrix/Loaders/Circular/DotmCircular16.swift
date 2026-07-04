import SwiftUI

/// Rail scan — alternating col 1/3 rails scanning rows, with proximity falloff.
public struct DotmCircular16: View {
    var props = DotMatrixCommonProps(pattern: .full)
    init(props: DotMatrixCommonProps) { self.props = props }

    /// Source-parity ergonomic init — mirrors `<DotmCircular16 size=… />` upstream. The
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

    private static let STEP_COUNT: Int = 25
    private static let BASE_OPACITY: Double = 0.07
    private static let MID_OPACITY: Double = 0.32
    private static let HIGH_OPACITY: Double = 0.95

    public var body: some View {
        DotMatrixBase(props: props) { ctx, now in
            guard isWithinCircularMask(row: ctx.row, col: ctx.col) else { return 0 }

            let animPhase = cyclePhase(now: now, cycleMsBase: 1700, speed: 1,
                                       active: !ctx.reducedMotion && ctx.phase != .idle)
            // Discrete steps: fractional animPhase breaks row === checks
            let t = ctx.reducedMotion || ctx.phase == .idle
                ? 0
                : Int(floor(animPhase * Double(Self.STEP_COUNT))) % Self.STEP_COUNT
            let activeRow = t % 5
            let activeBrailleCol = Int(floor(Double(t) / 5.0 * 2.0)) % 2
            let railCol = activeBrailleCol == 0 ? 1 : 3
            let nearCol = 2  // always col 2
            let rowDistance = abs(ctx.row - activeRow)

            var opacity = Self.BASE_OPACITY
            if ctx.col == railCol && rowDistance == 0 {
                opacity = Self.HIGH_OPACITY
            } else if ctx.col == railCol && rowDistance == 1 {
                opacity = Self.MID_OPACITY
            } else if ctx.col == nearCol && rowDistance == 0 {
                opacity = 0.52
            } else if (ctx.col == 1 || ctx.col == 3) && rowDistance == 2 {
                opacity = 0.24
            }

            return opacity
        }
    }
}
