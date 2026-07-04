import SwiftUI

/// Triangle 2 — altitude-weighted vertical pulse; each row lights slightly out
/// of phase so the wave climbs the triangle. Stepped cycle (36 steps, 1550ms).
/// Mirrors `dotm-triangle-2.tsx`.
public struct DotmTriangle2: View {
    var props = DotMatrixCommonProps(size: 30, dotSize: 4, pattern: .full)
    init(props: DotMatrixCommonProps) { self.props = props }

    /// Source-parity ergonomic init — mirrors `<DotmTriangle2 size=… />` upstream. The
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


    private static let STEP_COUNT = 36
    private static let BASE_OPACITY = 0.08
    private static let MID_OPACITY = 0.34
    private static let HIGH_OPACITY = 0.94

    public var body: some View {
        DotMatrixTriangleBase(props: props) { row, col, now, active in
            let frame = steppedCycle(
                now: now, cycleMsBase: 1550, steps: Self.STEP_COUNT, speed: 1, active: active)
            let progress = Double(frame) / Double(Self.STEP_COUNT)
            let rowPhase = Double(4 - row) * 0.13
            let pulse = 0.5 - 0.5 * cos((progress + rowPhase) * Double.pi * 2)
            let crest = pulse * pulse
            let altitudeWeight = 0.58 + Double(4 - row) * 0.16
            let centerWeight = col == 3 ? 0.16 : 0
            var opacity =
                Self.BASE_OPACITY
                + pulse * (Self.MID_OPACITY - Self.BASE_OPACITY)
                + crest * (altitudeWeight + centerWeight) * (Self.HIGH_OPACITY - Self.MID_OPACITY)
            opacity = min(Self.HIGH_OPACITY, opacity)
            return opacity
        }
    }
}
