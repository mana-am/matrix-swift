import SwiftUI

/// Heart-pulse beat — two harmonic spikes per cycle.
public struct DotmCircular8: View {
    var props = DotMatrixCommonProps(pattern: .full)
    init(props: DotMatrixCommonProps) { self.props = props }

    /// Source-parity ergonomic init — mirrors `<DotmCircular8 size=… />` upstream. The
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
    private static let PULSE_CORE: Double = 0.95
    private static let PULSE_RING: Double = 0.44

    public var body: some View {
        DotMatrixBase(props: props) { ctx, now in
            guard isWithinCircularMask(row: ctx.row, col: ctx.col) else { return 0 }

            let x = Double(ctx.col - 2)
            let y = Double(ctx.row - 2)
            let radius = (x * x + y * y).squareRoot()
            let phaseVal = (ctx.reducedMotion || ctx.phase == .idle)
                ? 0.0
                : cyclePhase(now: now, cycleMsBase: 1400, speed: 1, active: true)

            // Named locals to avoid type-checker timeout
            let beat = sin(phaseVal * .pi * 2)
            let spike = sin(phaseVal * .pi * 4)
            let pulse = max(0, beat) + max(0, spike) * 0.55

            if radius < 0.55 {
                return min(1, 0.35 + pulse * Self.PULSE_CORE)
            }
            if radius < 1.65 {
                return 0.16 + pulse * Self.PULSE_RING
            }
            return Self.BASE_OPACITY + pulse * 0.08
        }
    }
}
