import SwiftUI

/// Quantized brightness levels per column — bar chart effect, 1750ms.
public struct DotmSquare18: View {
    var props = DotMatrixCommonProps(pattern: .full)
    init(props: DotMatrixCommonProps) { self.props = props }

    /// Source-parity ergonomic init — mirrors `<DotmSquare18 size=… />` upstream. The
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
    private static let LIT: Double = 0.94
    private static let CAP: Double = 1
    private static let STEP_COUNT: Double = 24
    private static let MAX_LEVEL: Double = 5

    private static func clampLevel(_ value: Double) -> Double {
        max(1, min(MAX_LEVEL, (value).rounded()))
    }

    public var body: some View {
        DotMatrixBase(props: props) { ctx, now in
            let u: Double = (ctx.reducedMotion || ctx.phase == .idle) ? 0
                : cyclePhase(now: now, cycleMsBase: 1750, speed: 1, active: true)
            let t = u * Self.STEP_COUNT
            let colPhase = t * 0.52 + Double(ctx.col) * 1.15
            let level = Self.clampLevel(1 + ((sin(colPhase) + 1) / 2) * (Self.MAX_LEVEL - 1))
            let topLitRow = Int(Self.MAX_LEVEL - level)
            if ctx.row > topLitRow { return Self.LIT }
            if ctx.row == topLitRow { return Self.CAP }
            return Self.BASE
        }
    }
}
