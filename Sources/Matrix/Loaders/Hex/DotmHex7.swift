import SwiftUI

/// Glyph Cycle — 4-frame keyframe table: hex outline, midline burst, equator
/// pulse, vertex parity. Each cell is one of `x` (high) / `o` (mid) / unset
/// (base). Mirrors upstream `dotm-hex-7.tsx`.
public struct DotmHex7: View {
    var props = DotMatrixCommonProps(speed: 1.9, pattern: .full)
    init(props: DotMatrixCommonProps) { self.props = props }

    /// Source-parity ergonomic init — mirrors `<DotmHex7 size=… />` upstream. The
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


    private static let baseOp: Double = 0.20
    private static let midOp: Double = 0.32
    private static let highOp: Double = 0.98

    private enum Tone { case x, o, none }

    /// 4 frames × 19 cells, indexed `[frame][row][col]`. Built from upstream's
    /// `FRAMES` records by translating `"x" / "o"` into `Tone` and `nil`
    /// entries to `.none`. Indexing by row/col instead of dict for tight CPU.
    private static let frames: [[Tone]] = {
        // Helper: build a flat 19-entry array given a `(row, col): Tone` dict.
        func build(_ map: [String: Tone]) -> [Tone] {
            var out: [Tone] = []
            out.reserveCapacity(19)
            for r in 0..<HEX_ROWS {
                for c in 0..<HEX_ROW_COUNTS[r] {
                    out.append(map["\(r),\(c)"] ?? .none)
                }
            }
            return out
        }
        return [
            // Frame 0: top + bottom edges (x), upper/lower inner row (o), center (x)
            build([
                "0,0": .x, "0,1": .x, "0,2": .x,
                "1,1": .o, "1,2": .o,
                "2,2": .x,
                "3,1": .o, "3,2": .o,
                "4,0": .x, "4,1": .x, "4,2": .x
            ]),
            // Frame 1: midline ribbon
            build([
                "0,1": .o,
                "1,0": .x, "1,1": .x, "1,2": .x, "1,3": .x,
                "2,2": .o,
                "3,0": .x, "3,1": .x, "3,2": .x, "3,3": .x,
                "4,1": .o
            ]),
            // Frame 2: equator
            build([
                "0,1": .x,
                "1,1": .x, "1,2": .x,
                "2,0": .o, "2,1": .x, "2,2": .x, "2,3": .x, "2,4": .o,
                "3,1": .x, "3,2": .x,
                "4,1": .x
            ]),
            // Frame 3: vertex parity
            build([
                "0,0": .o, "0,2": .o,
                "1,0": .x, "1,3": .x,
                "2,1": .x, "2,2": .o, "2,3": .x,
                "3,0": .x, "3,3": .x,
                "4,0": .o, "4,2": .o
            ])
        ]
    }()

    public var body: some View {
        DotMatrixHexBase(props: props, timing: .stepped(steps: Self.frames.count, cycleMsBase: 1520)) {
            row, col, stepValue in
            let step = max(0, min(Self.frames.count - 1, Int(stepValue)))
            let flat = Self.flatIndex(row: row, col: col)
            switch Self.frames[step][flat] {
            case .x:    return Self.highOp
            case .o:    return Self.midOp
            case .none: return Self.baseOp
            }
        }
    }

    @inline(__always)
    private static func flatIndex(row: Int, col: Int) -> Int {
        var idx = 0
        for r in 0..<row { idx += HEX_ROW_COUNTS[r] }
        return idx + col
    }
}
