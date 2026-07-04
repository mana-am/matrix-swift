import SwiftUI

/// Helix on circle-mask grid.
public struct DotmCircular1: View {
    var props = DotMatrixCommonProps(pattern: .full)
    init(props: DotMatrixCommonProps) { self.props = props }

    /// Source-parity ergonomic init — mirrors `<DotmCircular1 size=… />` upstream. The
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
    private static let NEAR: Double = 0.24
    private static let STEP_COUNT: Double = 20
    private static let HELIX_LOOP_RADIANS: Double = (.pi * 2) / (STEP_COUNT - 1)

    public var body: some View {
        DotMatrixBase(props: props) { ctx, now in
            if !isWithinCircularMask(row: ctx.row, col: ctx.col) { return 0 }
            let u: Double = (ctx.reducedMotion || ctx.phase == .idle) ? 0
                : cyclePhase(now: now, cycleMsBase: 1700, speed: 1, active: true)
            let t = u * Self.STEP_COUNT
            let diagonalAxis = Double(ctx.row + ctx.col)
            let phaseOffset = t * Self.HELIX_LOOP_RADIANS + diagonalAxis * 0.82
            let strandPerp = Int((2 * sin(phaseOffset)).rounded())
            let cellPerp = ctx.col - ctx.row
            let dist = abs(cellPerp - strandPerp)
            if dist == 0 { return Self.STRAND }
            if dist == 1 { return Self.NEAR }
            return Self.BASE
        }
    }
}
