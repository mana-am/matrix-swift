import SwiftUI

/// Single strand sweeping across full 5-column width, 1600ms.
public struct DotmSquare17: View {
    var props = DotMatrixCommonProps(pattern: .full)
    init(props: DotMatrixCommonProps) { self.props = props }

    /// Source-parity ergonomic init — mirrors `<DotmSquare17 size=… />` upstream. The
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


    private static let BASE: Double = 0.08
    private static let STRAND: Double = 1
    private static let NEAR_STRAND: Double = 0.24
    private static let STEP_COUNT: Double = 20
    private static let HELIX_LOOP_RADIANS: Double = (.pi * 2) / (STEP_COUNT - 1)

    public var body: some View {
        DotMatrixBase(props: props) { ctx, now in
            let u: Double = (ctx.reducedMotion || ctx.phase == .idle) ? 0
                : cyclePhase(now: now, cycleMsBase: 1600, speed: 1, active: true)
            let t = u * Self.STEP_COUNT
            let rowPhase = t * Self.HELIX_LOOP_RADIANS + Double(ctx.row) * 1.24
            let strandCol = Int((2.0 + 2.0 * sin(rowPhase)).rounded())
            if ctx.col == strandCol { return Self.STRAND }
            if abs(ctx.col - strandCol) == 1 { return Self.NEAR_STRAND }
            return Self.BASE
        }
    }
}
