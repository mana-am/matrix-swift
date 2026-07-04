import SwiftUI

/// Petal blade × radial gate pinwheel.
public struct DotmCircular5: View {
    var props = DotMatrixCommonProps(pattern: .full)
    init(props: DotMatrixCommonProps) { self.props = props }

    /// Source-parity ergonomic init — mirrors `<DotmCircular5 size=… />` upstream. The
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

    private static let BASE_OPACITY: Double = 0.08
    private static let BLADE_OPACITY: Double = 0.94
    private static let HALO_OPACITY: Double = 0.34

    public var body: some View {
        DotMatrixBase(props: props) { ctx, now in
            guard isWithinCircularMask(row: ctx.row, col: ctx.col) else { return 0 }

            let x = Double(ctx.col - 2)
            let y = Double(ctx.row - 2)
            let radius = (x * x + y * y).squareRoot()
            let angle = atan2(y, x)
            let phaseVal = (ctx.reducedMotion || ctx.phase == .idle)
                ? 0.0
                : cyclePhase(now: now, cycleMsBase: 1650, speed: 1, active: true)
            let theta = phaseVal * .pi * 2

            if radius < 0.6 {
                return 0.66
            }

            // Split long expression into named locals to avoid type-checker timeout
            let pinwheel = cos(angle * 4 - theta * 2.2)
            let radialGate = sin(radius * 2.1 - theta * 1.25)

            if pinwheel > 0.48 && radialGate > -0.25 {
                return Self.BLADE_OPACITY
            }
            if pinwheel > 0.1 {
                return Self.HALO_OPACITY
            }
            return Self.BASE_OPACITY
        }
    }
}
