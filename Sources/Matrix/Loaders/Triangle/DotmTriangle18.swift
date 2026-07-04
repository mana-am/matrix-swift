import SwiftUI

/// Triangle 18 — the heart cell stays dim while the outer shell breathes in sync
/// (inverted emphasis vs center-led coronas). Cycle (1600ms).
/// Mirrors `dotm-triangle-18.tsx`.
public struct DotmTriangle18: View {
    var props = DotMatrixCommonProps(size: 30, dotSize: 4, pattern: .full)
    init(props: DotMatrixCommonProps) { self.props = props }

    /// Source-parity ergonomic init — mirrors `<DotmTriangle18 size=… />` upstream. The
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


    private static let CORE_DIM = 0.1
    private static let SHELL_LOW = 0.22
    private static let SHELL_HIGH = 0.96

    private static func opacityForCell(_ row: Int, _ col: Int, _ phase: Double) -> Double {
        if row == 3 && col == 3 { return CORE_DIM }
        let breathe = 0.5 + 0.5 * sin(phase * Double.pi * 2)
        let crest = dmHexSmoothstep01(0.2, 0.94, breathe)
        return SHELL_LOW + crest * (SHELL_HIGH - SHELL_LOW)
    }

    public var body: some View {
        DotMatrixTriangleBase(props: props) { row, col, now, active in
            let phase = active ? cyclePhase(now: now, cycleMsBase: 1600, speed: 1, active: true) : 0.2
            return Self.opacityForCell(row, col, phase)
        }
    }
}
