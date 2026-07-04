import SwiftUI

/// Chevron March — chevron bands march down + up, crossing through the
/// center in a v-shape. Mirrors upstream `dotm-hex-6.tsx`.
public struct DotmHex6: View {
    var props = DotMatrixCommonProps(speed: 1.55, pattern: .full)
    init(props: DotMatrixCommonProps) { self.props = props }

    /// Source-parity ergonomic init — mirrors `<DotmHex6 size=… />` upstream. The
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


    private static let bandCount: Double = 4
    private static let baseOp: Double = 0.10
    private static let highOp: Double = 0.98

    public var body: some View {
        DotMatrixHexBase(props: props, timing: .cycle(cycleMsBase: 1500)) { row, col, phase in
            let count = HEX_ROW_COUNTS[row]
            let x = Double(col) - Double(count - 1) / 2
            let y = Double(row - 2)
            let downward = y + abs(x) * 0.92 + 1.55
            let upward = -y + abs(x) * 0.92 + 1.55
            let head = phase * Self.bandCount
            let primary = max(
                0, 1 - dmHexWrappedDistance(downward, head, mod: Self.bandCount) / 0.78
            )
            let secondary = max(
                0,
                1 - dmHexWrappedDistance(upward, head + Self.bandCount / 2, mod: Self.bandCount) / 0.92
            )
            let centerLift = (row == 2 && col == 2) ? 0.18 : 0
            return min(Self.highOp, Self.baseOp + primary * 0.78 + secondary * 0.38 + centerLift)
        }
    }
}
