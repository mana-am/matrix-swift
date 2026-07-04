import SwiftUI

/// 5-petal × ring × chord blend with sharpened contrast.
public struct DotmCircular7: View {
    var props = DotMatrixCommonProps(pattern: .full)
    init(props: DotMatrixCommonProps) { self.props = props }

    /// Source-parity ergonomic init — mirrors `<DotmCircular7 size=… />` upstream. The
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
    private static let GATE_OPACITY: Double = 0.92

    public var body: some View {
        DotMatrixBase(props: props) { ctx, now in
            guard isWithinCircularMask(row: ctx.row, col: ctx.col) else { return 0 }

            let x = Double(ctx.col - 2)
            let y = Double(ctx.row - 2)
            let phaseVal = (ctx.reducedMotion || ctx.phase == .idle)
                ? 0.0
                : cyclePhase(now: now, cycleMsBase: 1600, speed: 1, active: true)
            let t = phaseVal * .pi * 2
            let ring = (x * x + y * y).squareRoot()
            let angle = atan2(y, x)

            // Named locals to avoid type-checker timeout
            let petalWave = 0.5 + 0.5 * cos(5 * angle - t * 1.7)
            let ringWave = 0.5 + 0.5 * cos(ring * 3.3 - t * 1.2)
            let chordWave = 0.5 + 0.5 * cos((x + y) * 1.6 + t * 1.35)

            // Sharpen contrast so lit cells form clear, visible groups
            let petalGate = pow(petalWave, 2.2)
            let blend = 0.68 * petalGate + 0.22 * ringWave + 0.1 * chordWave
            let opacity = Self.BASE_OPACITY + (Self.GATE_OPACITY - Self.BASE_OPACITY) * blend

            return opacity
        }
    }
}
