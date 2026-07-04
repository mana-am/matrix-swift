import SwiftUI

/// Scan row + exp decay trail + col-warp.
public struct DotmSquare10: View {
    var props = DotMatrixCommonProps(pattern: .full)
    init(props: DotMatrixCommonProps) { self.props = props }

    /// Source-parity ergonomic init — mirrors `<DotmSquare10 size=… />` upstream. The
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


    private static let ROWS = 5
    private static let BASE_OPACITY: Double = 0.08
    private static let PEAK_OPACITY: Double = 1
    private static let DECAY: Double = 0.72
    private static let COL_WARP: Double = 0.07

    public var body: some View {
        DotMatrixBase(props: props) { ctx, now in
            if ctx.reducedMotion || ctx.phase == .idle {
                let falloff = Double(Self.ROWS - 1 - ctx.row) / Double(max(1, Self.ROWS - 1))
                return Self.BASE_OPACITY + falloff * 0.38
            }

            let scanRow = steppedCycle(now: now, cycleMsBase: 1500, steps: Self.ROWS, speed: 1, active: true)
            let colGain = 1 + Self.COL_WARP * sin(Double(ctx.col) * 1.72 + Double(scanRow) * 0.61)

            if ctx.row > scanRow { return Self.BASE_OPACITY }

            let age = scanRow - ctx.row
            let trail = exp(-Double(age) * Self.DECAY)
            let opacity = Self.BASE_OPACITY + (Self.PEAK_OPACITY - Self.BASE_OPACITY) * trail * colGain
            return min(Self.PEAK_OPACITY, opacity)
        }
    }
}
