import SwiftUI

/// Vertex Chase — head walks the 9 outer vertex points; each vertex echoes
/// to its two adjacent inner cells with a softer glow. Mirrors upstream
/// `dotm-hex-4.tsx`.
public struct DotmHex4: View {
    var props = DotMatrixCommonProps(speed: 1.5, pattern: .full)
    init(props: DotMatrixCommonProps) { self.props = props }

    /// Source-parity ergonomic init — mirrors `<DotmHex4 size=… />` upstream. The
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


    private static let vertices: [String] = [
        "0,2", "1,3", "2,4",
        "3,3", "4,2",
        "3,0", "2,0", "1,0", "0,0"
    ]
    private static let pathLen = Double(vertices.count)
    private static let trailSpan: Double = 2.2
    private static let baseOp: Double = 0.08
    private static let midOp: Double = 0.36
    private static let highOp: Double = 0.98

    /// Echo cells per vertex, mirroring upstream `ECHO_BY_VERTEX`.
    private static let echo: [String: [String]] = [
        "0,2": ["0,1", "1,2"],
        "1,3": ["1,2", "2,3"],
        "2,4": ["2,3", "2,2"],
        "3,3": ["3,2", "2,3"],
        "4,2": ["4,1", "3,2"],
        "3,0": ["3,1", "2,1"],
        "2,0": ["2,1", "2,2"],
        "1,0": ["1,1", "2,1"],
        "0,0": ["0,1", "1,1"]
    ]

    public var body: some View {
        DotMatrixHexBase(props: props, timing: .cycle(cycleMsBase: 1700)) { row, col, phase in
            let id = HexCell.id(row: row, col: col)
            let head = phase * Self.pathLen
            var op = Self.baseOp
            if let idx = Self.vertices.firstIndex(of: id) {
                let distance = dmHexModF(head - Double(idx), Self.pathLen)
                let glow = max(0, 1 - distance / Self.trailSpan)
                op = max(op, Self.baseOp + glow * (Self.highOp - Self.baseOp))
            }
            // Echo: any vertex whose echo list contains this id contributes
            // a fraction of the vertex's glow.
            for (vIdString, echoes) in Self.echo where echoes.contains(id) {
                if let idx = Self.vertices.firstIndex(of: vIdString) {
                    let distance = dmHexModF(head - Double(idx), Self.pathLen)
                    let glow = max(0, 1 - distance / Self.trailSpan)
                    op = max(op, Self.baseOp + glow * (Self.midOp - Self.baseOp))
                }
            }
            return min(Self.highOp, op)
        }
    }
}
