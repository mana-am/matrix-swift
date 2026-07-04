import SwiftUI

/// Hourglass Flip — 4 frames flip between hourglass and equator. Mirrors
/// upstream `dotm-hex-8.tsx`.
struct DotmHex8: View {
    var props = DotMatrixCommonProps(speed: 1.35, pattern: .full)

    private static let baseOp: Double = 0.20
    private static let midOp: Double = 0.46
    private static let highOp: Double = 0.98

    private enum Tone { case x, o, none }

    private static let frames: [[Tone]] = {
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
            build([
                "0,1": .x, "1,1": .o, "1,2": .o,
                "2,0": .x, "2,2": .x, "2,4": .x,
                "3,1": .o, "3,2": .o, "4,1": .x
            ]),
            build([
                "0,0": .x, "0,2": .x,
                "1,0": .o, "1,3": .o,
                "2,1": .x, "2,2": .o, "2,3": .x,
                "3,0": .o, "3,3": .o,
                "4,0": .x, "4,2": .x
            ]),
            build([
                "0,1": .o, "1,0": .x, "1,3": .x,
                "2,0": .o, "2,2": .x, "2,4": .o,
                "3,0": .x, "3,3": .x, "4,1": .o
            ]),
            build([
                "0,0": .o, "0,2": .o,
                "1,1": .x, "1,2": .x,
                "2,1": .o, "2,3": .o,
                "3,1": .x, "3,2": .x,
                "4,0": .o, "4,2": .o
            ])
        ]
    }()

    var body: some View {
        DotMatrixHexBase(props: props, timing: .stepped(steps: Self.frames.count, cycleMsBase: 1400)) {
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
