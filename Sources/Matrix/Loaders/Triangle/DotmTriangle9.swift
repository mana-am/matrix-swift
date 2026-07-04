import SwiftUI

/// Triangle 9 — concentric tiers from the heart (8-connected BFS rings); one soft
/// bright band travels outward. Cycle (1800ms). Mirrors `dotm-triangle-9.tsx`.
public struct DotmTriangle9: View {
    var props = DotMatrixCommonProps(size: 30, dotSize: 4, pattern: .full)
    init(props: DotMatrixCommonProps) { self.props = props }

    /// Source-parity ergonomic init — mirrors `<DotmTriangle9 size=… />` upstream. The
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


    private static let BASE_OPACITY = 0.14
    private static let HIGH_OPACITY = 0.96

    /// BFS ring distance from the heart cell (3,3), 8-connected within the mask.
    /// Precomputed (equivalent to `buildBfsRingFromCenter`): ring 0 = heart,
    /// 1 = mid wings, 2 = apex/inner wings, 3 = base corners.
    private static let ring: [Int: Int] = [
        idx(3, 3): 0,
        idx(2, 2): 1, idx(2, 4): 1, idx(4, 2): 1, idx(4, 4): 1,
        idx(1, 3): 2, idx(3, 1): 2, idx(3, 5): 2,
        idx(4, 0): 3, idx(4, 6): 3,
    ]
    private static let MAX_RING = 3

    private static func idx(_ r: Int, _ c: Int) -> Int { r * 7 + c }

    private static func opacityForCell(_ row: Int, _ col: Int, _ phase: Double) -> Double {
        let r = Double(ring[idx(row, col)] ?? 0)
        let span = Double(max(1, MAX_RING))
        let t = phase * Double.pi * 2
        let u = (r / span) * Double.pi * 2 - t
        let wave = 0.5 + 0.5 * cos(u)
        let crest = dmHexSmoothstep01(0.35, 1, wave)
        return min(HIGH_OPACITY, BASE_OPACITY + crest * (HIGH_OPACITY - BASE_OPACITY))
    }

    public var body: some View {
        DotMatrixTriangleBase(props: props) { row, col, now, active in
            let phase = active ? cyclePhase(now: now, cycleMsBase: 1800, speed: 1, active: true) : 0.18
            return Self.opacityForCell(row, col, phase)
        }
    }
}
