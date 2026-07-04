import SwiftUI

/// Triangle 12 — anti-diagonal harmonics on `row - col`: bands glide along NE–SW
/// lines. Cycle (2300ms). Mirrors `dotm-triangle-12.tsx`.
public struct DotmTriangle12: View {
    var props = DotMatrixCommonProps(size: 30, dotSize: 4, pattern: .full)
    init(props: DotMatrixCommonProps) { self.props = props }

    /// Source-parity ergonomic init — mirrors `<DotmTriangle12 size=… />` upstream. The
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


    private static let BASE_OPACITY = 0.06
    private static let MID_OPACITY = 0.34
    private static let HIGH_OPACITY = 0.96

    private static func opacityForCell(_ row: Int, _ col: Int, _ phase: Double) -> Double {
        let skew = Double(row - col)
        let t = phase * Double.pi * 2
        let u = skew * 0.62 - t * 1.45
        let primary = 0.5 + 0.5 * cos(u)
        let harmonic = 0.5 + 0.5 * cos(u * 2 - 0.55)
        let pSoft = dmHexSmoothstep01(0.12, 0.95, primary)
        let hSoft = dmHexSmoothstep01(0.38, 0.92, harmonic)
        let crest = pSoft * pSoft * 0.88 + max(0, hSoft - 0.42) * 0.32
        var opacity = BASE_OPACITY + crest * (HIGH_OPACITY - BASE_OPACITY)
        if row == 3 && col == 3 {
            opacity = max(opacity, MID_OPACITY + (crest - 0.22) * 0.4)
        }
        return min(HIGH_OPACITY, opacity)
    }

    public var body: some View {
        DotMatrixTriangleBase(props: props) { row, col, now, active in
            let phase = active ? cyclePhase(now: now, cycleMsBase: 2300, speed: 1, active: true) : 0.2
            return Self.opacityForCell(row, col, phase)
        }
    }
}
