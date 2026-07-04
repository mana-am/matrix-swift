import SwiftUI

/// Helix strand — left & right strand + bridge + near-strand.
public struct DotmSquare15: View {
    var props = DotMatrixCommonProps(pattern: .full)
    init(props: DotMatrixCommonProps) { self.props = props }

    /// Source-parity ergonomic init — mirrors `<DotmSquare15 size=… />` upstream. The
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
    private static let BRIDGE: Double = 0.58
    private static let NEAR_STRAND: Double = 0.24
    private static let STRAND_LOOPS: Double = 2

    public var body: some View {
        DotMatrixBase(props: props) { ctx, now in
            let u: Double = (ctx.reducedMotion || ctx.phase == .idle) ? 0
                : cyclePhase(now: now, cycleMsBase: 1600, speed: 1, active: true)
            let rowPhase = u * Self.STRAND_LOOPS * 2 * .pi + Double(ctx.row) * 1.24
            let left = Int((1.0 + sin(rowPhase)).rounded())
            let right = 4 - left
            let bridgeOn = cos(rowPhase * 2) > 0.82
            if ctx.col == left || ctx.col == right { return Self.STRAND }
            if bridgeOn && ctx.col > left && ctx.col < right { return Self.BRIDGE }
            if abs(ctx.col - left) == 1 || abs(ctx.col - right) == 1 { return Self.NEAR_STRAND }
            return Self.BASE
        }
    }
}
