import SwiftUI

/// Hex Orbit — head sweeps the hex perimeter, trail decays via smoothstep.
/// Mirrors upstream `dotm-hex-1.tsx` (commit 61b8cb07).
public struct DotmHex1: View {
    var props = DotMatrixCommonProps(speed: 1.6, pattern: .full)
    init(props: DotMatrixCommonProps) { self.props = props }

    /// Source-parity ergonomic init — mirrors `<DotmHex1 size=… />` upstream. The
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


    private static let perimeter: [String] = [
        "0,0", "0,1", "0,2",
        "1,3", "2,4", "3,3",
        "4,2", "4,1", "4,0",
        "3,0", "2,0", "1,0"
    ]
    private static let pathLen = Double(perimeter.count)
    private static let trailSpan: Double = 5
    private static let baseOp: Double = 0.10
    private static let highOp: Double = 0.96
    private static let centerOp: Double = 0.10

    public var body: some View {
        DotMatrixHexBase(props: props, timing: .cycle(cycleMsBase: 1500)) { row, col, phase in
            let id = HexCell.id(row: row, col: col)
            if id == "2,2" { return Self.centerOp }
            guard let pathIdx = Self.perimeter.firstIndex(of: id) else { return Self.baseOp }
            let head = phase * Self.pathLen
            let distance = dmHexModF(head - Double(pathIdx), Self.pathLen)
            let glow = 1 - dmHexSmoothstep01(0, Self.trailSpan, distance)
            return Self.baseOp + glow * (Self.highOp - Self.baseOp)
        }
    }
}
