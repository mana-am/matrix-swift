import SwiftUI

/// Triangle 8 — alternating emphasis on the two lower wings (split by the apex
/// column); the apex + heart brighten as energy crosses the middle. Cycle
/// (1500ms). Mirrors `dotm-triangle-8.tsx`.
public struct DotmTriangle8: View {
    var props = DotMatrixCommonProps(size: 30, dotSize: 4, pattern: .full)
    init(props: DotMatrixCommonProps) { self.props = props }

    /// Source-parity ergonomic init — mirrors `<DotmTriangle8 size=… />` upstream. The
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


    private static let BASE_OPACITY = 0.05
    private static let MID_OPACITY = 0.42
    private static let HIGH_OPACITY = 0.96

    private enum Sector { case left, right, spine, none }

    private static func sector(_ row: Int, _ col: Int) -> Sector {
        if row == 1 && col == 3 { return .spine }
        if row == 3 && col == 3 { return .spine }
        switch (row, col) {
        case (2, 2), (3, 1), (4, 0), (4, 2): return .left
        case (2, 4), (3, 5), (4, 4), (4, 6): return .right
        default: return .none
        }
    }

    private static func opacityForCell(_ row: Int, _ col: Int, _ phase: Double) -> Double {
        let p = 0.5 - 0.5 * cos(phase * Double.pi * 2)
        let leftLift = p * p
        let rightLift = (1 - p) * (1 - p)
        let crossover = max(0, 1 - 4 * (p - 0.5) * (p - 0.5))

        switch sector(row, col) {
        case .none:
            return 0
        case .spine:
            if row == 1 && col == 3 {
                let apex = MID_OPACITY + crossover * (HIGH_OPACITY - MID_OPACITY) * 0.95
                return min(HIGH_OPACITY, apex)
            }
            let hub =
                BASE_OPACITY + crossover * 0.55 * (HIGH_OPACITY - BASE_OPACITY)
                + leftLift * 0.08 + rightLift * 0.08
            return min(HIGH_OPACITY, hub)
        case .left:
            return min(HIGH_OPACITY, BASE_OPACITY + leftLift * (HIGH_OPACITY - BASE_OPACITY))
        case .right:
            return min(HIGH_OPACITY, BASE_OPACITY + rightLift * (HIGH_OPACITY - BASE_OPACITY))
        }
    }

    public var body: some View {
        DotMatrixTriangleBase(props: props) { row, col, now, active in
            let phase = active ? cyclePhase(now: now, cycleMsBase: 1500, speed: 1, active: true) : 0.25
            return Self.opacityForCell(row, col, phase)
        }
    }
}
