import SwiftUI

/// Triangle 5 — a horizontal scan line ping-pongs up and down the silhouette
/// with a soft beam falloff. Stepped cycle (42 steps, 1700ms).
/// Mirrors `dotm-triangle-5.tsx`.
public struct DotmTriangle5: View {
    var props = DotMatrixCommonProps(size: 30, dotSize: 4, pattern: .full)
    init(props: DotMatrixCommonProps) { self.props = props }

    /// Source-parity ergonomic init — mirrors `<DotmTriangle5 size=… />` upstream. The
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


    private static let STEP_COUNT = 42
    private static let BASE_OPACITY = 0.06
    private static let MID_OPACITY = 0.3
    private static let HIGH_OPACITY = 0.92

    public var body: some View {
        DotMatrixTriangleBase(props: props) { row, col, now, active in
            let frame = steppedCycle(
                now: now, cycleMsBase: 1700, steps: Self.STEP_COUNT, speed: 1, active: active)
            let progress = Double(frame) / Double(Self.STEP_COUNT)
            let pingPong = 0.5 - 0.5 * cos(progress * Double.pi * 2)
            let scanRow = 1 + pingPong * 3

            let distance = abs(Double(row) - scanRow)
            let beam = max(0, 1 - distance / 2.2)
            let easedBeam = beam * beam
            var opacity = Self.BASE_OPACITY + easedBeam * (Self.HIGH_OPACITY - Self.BASE_OPACITY)
            if distance > 1.3 {
                opacity = max(opacity, Self.MID_OPACITY - min(0.18, (distance - 1.3) * 0.12))
            }
            if row == 3 && col == 3 { opacity = max(opacity, 0.42) }
            return opacity
        }
    }
}
