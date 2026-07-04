import SwiftUI

/// Liquid Vortex — a sinusoidal lens slides across the grid leaving
/// dual ripples + a vertical compression beat + outer shell sheen.
/// Mirrors upstream `dotm-hex-10.tsx`.
public struct DotmHex10: View {
    var props = DotMatrixCommonProps(speed: 1.55, pattern: .full)
    init(props: DotMatrixCommonProps) { self.props = props }

    /// Source-parity ergonomic init — mirrors `<DotmHex10 size=… />` upstream. The
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


    private static let baseOp: Double = 0.09
    private static let highOp: Double = 0.98

    public var body: some View {
        DotMatrixHexBase(props: props, timing: .cycle(cycleMsBase: 1850)) { row, col, phase in
            let p = HexCell.point(row: row, col: col)
            let radius = sqrt(p.x * p.x + p.y * p.y)
            let lensCenter = sin(phase * .pi * 2) * 1.15
            let lensDistance = abs(lensCenter - p.x * 0.88 - p.y * 0.16)
            let liquidLens = max(0, 1 - lensDistance / 0.78)
            let wakeFront = dmHexRipple(phase + p.x * 0.12 - p.y * 0.045 + radius * 0.07, width: 0.16)
            let wakeBack = dmHexRipple(
                phase + 0.34 + p.x * 0.09 + p.y * 0.035 + radius * 0.05, width: 0.2
            ) * 0.34
            let verticalCompression = max(
                0, 1 - abs(cos(phase * .pi * 2) * 1.18 - p.y * 1.25) / 1.1
            ) * 0.18
            let shellSheen = (0.5 + 0.5 * sin(phase * .pi * 2 - radius * 1.9))
                * (radius > 1.35 ? 0.16 : 0.06)
            let core = radius < 0.1 ? 0.34 + sin(phase * .pi * 2) * 0.1 : 0
            return min(
                Self.highOp,
                Self.baseOp + liquidLens * 0.72 + wakeFront * 0.38 + wakeBack
                    + verticalCompression + shellSheen + core
            )
        }
    }
}
