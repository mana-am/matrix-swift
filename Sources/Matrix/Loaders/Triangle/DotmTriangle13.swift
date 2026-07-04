import SwiftUI

/// Triangle 13 — row serpent: a soft head zigzags the silhouette (base row L→R,
/// row 3 R→L, mid rows alternate) with a smooth trailing ramp. Cycle (1400ms).
/// Mirrors `dotm-triangle-13.tsx`.
public struct DotmTriangle13: View {
    var props = DotMatrixCommonProps(size: 30, dotSize: 4, pattern: .full)
    init(props: DotMatrixCommonProps) { self.props = props }

    /// Source-parity ergonomic init — mirrors `<DotmTriangle13 size=… />` upstream. The
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


    private static let BASE_OPACITY = 0.13
    private static let HIGH_OPACITY = 0.95
    private static let TRAIL_SPAN = 4.25
    private static let PATH: [(Int, Int)] = [
        (4, 0), (4, 2), (4, 4), (4, 6), (3, 5), (3, 3), (3, 1), (2, 2), (2, 4), (1, 3),
    ]

    private static func pathIndex(_ row: Int, _ col: Int) -> Int? {
        for (i, p) in PATH.enumerated() where p.0 == row && p.1 == col { return i }
        return nil
    }

    private static func opacityForCell(_ row: Int, _ col: Int, _ phase: Double) -> Double {
        guard let idx = pathIndex(row, col) else { return 0 }
        let pathLen = Double(PATH.count)
        let s = phase * pathLen
        let d = dmHexModF(s - Double(idx), pathLen)
        let g = 1 - dmHexSmoothstep01(0, TRAIL_SPAN, d)
        return BASE_OPACITY + g * (HIGH_OPACITY - BASE_OPACITY)
    }

    public var body: some View {
        DotMatrixTriangleBase(props: props) { row, col, now, active in
            let phase = active ? cyclePhase(now: now, cycleMsBase: 1400, speed: 1, active: true) : 0.14
            return Self.opacityForCell(row, col, phase)
        }
    }
}
