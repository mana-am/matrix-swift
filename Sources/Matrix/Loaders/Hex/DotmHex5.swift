import SwiftUI

/// Spiral Lattice — clockwise + counter-clockwise spirals overlap with a
/// pulsing core. Mirrors upstream `dotm-hex-5.tsx`.
public struct DotmHex5: View {
    var props = DotMatrixCommonProps(speed: 1.75, pattern: .full)
    init(props: DotMatrixCommonProps) { self.props = props }

    /// Source-parity ergonomic init — mirrors `<DotmHex5 size=… />` upstream. The
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


    private static let baseOp: Double = 0.08
    private static let highOp: Double = 0.96

    @inline(__always)
    private static func wavePeak(_ value: Double) -> Double {
        let wrapped = dmHexModF(value, 1)
        return max(0, 1 - abs(wrapped * 2 - 1) / 0.55)
    }

    public var body: some View {
        DotMatrixHexBase(props: props, timing: .cycle(cycleMsBase: 1500)) { row, col, phase in
            let polar = HexCell.polar(row: row, col: col)
            let spiral = phase + polar.radius * 0.18 + polar.angle / (.pi * 2)
            let counter = phase * 0.72 - polar.radius * 0.16 - polar.angle / (.pi * 2)
            let a = Self.wavePeak(spiral)
            let b = Self.wavePeak(counter) * 0.55
            let core = polar.radius < 0.1 ? 0.54 + sin(phase * .pi * 4) * 0.26 : 0
            return min(Self.highOp, Self.baseOp + a * 0.7 + b * 0.42 + core)
        }
    }
}
