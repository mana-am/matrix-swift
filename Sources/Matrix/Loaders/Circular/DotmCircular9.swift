import SwiftUI

/// Beacon — sweeps cardinal directions, pair of beams (active + opposite).
public struct DotmCircular9: View {
    var props = DotMatrixCommonProps(pattern: .full)
    init(props: DotMatrixCommonProps) { self.props = props }

    /// Source-parity ergonomic init — mirrors `<DotmCircular9 size=… />` upstream. The
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

    private static let STEP_COUNT: Int = 36
    private static let BASE_OPACITY: Double = 0.07
    private static let MID_OPACITY: Double = 0.28
    private static let STAR_OPACITY: Double = 0.96
    private static let CARDINAL_CENTERS: [Double] = [0, .pi / 2, .pi, -.pi / 2]

    public var body: some View {
        DotMatrixBase(props: props) { ctx, now in
            guard isWithinCircularMask(row: ctx.row, col: ctx.col) else { return 0 }

            let x = Double(ctx.col - 2)
            let y = Double(ctx.row - 2)
            let ring = (x * x + y * y).squareRoot()
            let angle = atan2(y, x)
            let step = steppedCycle(
                now: now, cycleMsBase: 1900, steps: Self.STEP_COUNT, speed: 1,
                active: !ctx.reducedMotion && ctx.phase != .idle)
            let beaconIndex = Int(floor(Double(step) / Double(Self.STEP_COUNT) * 4))
                % Self.CARDINAL_CENTERS.count
            let activeCenter = Self.CARDINAL_CENTERS[beaconIndex]
            let oppositeCenter = Self.CARDINAL_CENTERS[(beaconIndex + 2) % Self.CARDINAL_CENTERS.count]

            // acos(cos(x)) = |x| wrapped to [0, π] — angular distance
            let distanceToActive = acos(cos(angle - activeCenter))
            let distanceToOpposite = acos(cos(angle - oppositeCenter))
            let activeBeam = max(0, 1 - distanceToActive / 0.5)
            let oppositeBeam = max(0, 1 - distanceToOpposite / 0.65)
            let ringTier = Int(ring.rounded())

            var opacity = Self.BASE_OPACITY
            if activeBeam > 0.8 && ringTier >= 2 {
                opacity = Self.STAR_OPACITY
            } else if activeBeam > 0.45 && ringTier >= 1 {
                opacity = 0.62
            } else if oppositeBeam > 0.5 && ringTier >= 1 {
                opacity = Self.MID_OPACITY
            }

            if x == 0 && y == 0 {
                return max(opacity, 0.24)
            }
            return opacity
        }
    }
}
