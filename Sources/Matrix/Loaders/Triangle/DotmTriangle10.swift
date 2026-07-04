import SwiftUI

/// Triangle 10 — a head rakes column-by-column (bottom-to-top within each column)
/// with a 4-level tail. Stepped cycle (36 steps, 1750ms).
/// Mirrors `dotm-triangle-10.tsx`.
public struct DotmTriangle10: View {
    var props = DotMatrixCommonProps(size: 30, dotSize: 4, pattern: .full)
    init(props: DotMatrixCommonProps) { self.props = props }

    /// Source-parity ergonomic init — mirrors `<DotmTriangle10 size=… />` upstream. The
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
    private static let BASE_OPACITY = 0.07
    private static let TAIL_LEVELS: [Double] = [0.94, 0.68, 0.42, 0.24]
    private static let PATH: [(Int, Int)] = [
        (4, 0), (3, 1), (4, 2), (2, 2), (3, 3), (1, 3), (4, 4), (2, 4), (4, 6), (3, 5),
    ]

    public var body: some View {
        DotMatrixTriangleBase(props: props) { row, col, now, active in
            let frame = steppedCycle(
                now: now, cycleMsBase: 1750, steps: Self.STEP_COUNT, speed: 1, active: active)
            let pathLen = Self.PATH.count
            let head = Int(floor((Double(frame) / Double(Self.STEP_COUNT)) * Double(pathLen))) % pathLen
            var opacity = Self.BASE_OPACITY
            for trail in 0..<Self.TAIL_LEVELS.count {
                let idx = (head - trail + pathLen) % pathLen
                let p = Self.PATH[idx]
                if row == p.0 && col == p.1 {
                    opacity = max(opacity, Self.TAIL_LEVELS[trail])
                    break
                }
            }
            return opacity
        }
    }
}
