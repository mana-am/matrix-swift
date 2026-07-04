import SwiftUI

/// Triangle 19 — a soft rotating wedge from the heart: brightness peaks where the
/// polar angle matches the spinning phase (searchlight pivot). Cycle (1400ms).
/// Mirrors `dotm-triangle-19.tsx`.
public struct DotmTriangle19: View {
    var props = DotMatrixCommonProps(size: 30, dotSize: 4, pattern: .full)
    init(props: DotMatrixCommonProps) { self.props = props }

    /// Source-parity ergonomic init — mirrors `<DotmTriangle19 size=… />` upstream. The
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


    private static let BASE_OPACITY = 0.08
    private static let MID_OPACITY = 0.38
    private static let HIGH_OPACITY = 0.96
    private static let CENTER_ROW = 3
    private static let CENTER_COL = 3
    private static let BEAM_SIGMA = 0.58

    private static func angleDiff(_ a: Double, _ b: Double) -> Double {
        var d = a - b
        while d > Double.pi { d -= Double.pi * 2 }
        while d < -Double.pi { d += Double.pi * 2 }
        return d
    }

    private static func opacityForCell(_ row: Int, _ col: Int, _ phase: Double) -> Double {
        if row == CENTER_ROW && col == CENTER_COL {
            let hub = 0.5 + 0.5 * sin(phase * Double.pi * 2)
            let hubSoft = dmHexSmoothstep01(0.12, 0.9, hub)
            return MID_OPACITY + hubSoft * 0.22
        }
        let t = phase * Double.pi * 2
        let ang = atan2(Double(row - CENTER_ROW), Double(col - CENTER_COL))
        let d = angleDiff(ang, t)
        let beamRaw = exp(-(d * d) / (BEAM_SIGMA * BEAM_SIGMA))
        let beam = dmHexSmoothstep01(0.05, 0.98, beamRaw)
        let rim = 0.5 + 0.5 * cos(ang * 2 - t * 1.15)
        let accent = dmHexSmoothstep01(0.45, 0.92, rim) * 0.18
        return min(HIGH_OPACITY, BASE_OPACITY + (beam + accent) * (HIGH_OPACITY - BASE_OPACITY))
    }

    public var body: some View {
        DotMatrixTriangleBase(props: props) { row, col, now, active in
            let phase = active ? cyclePhase(now: now, cycleMsBase: 1400, speed: 1, active: true) : 0.12
            return Self.opacityForCell(row, col, phase)
        }
    }
}
