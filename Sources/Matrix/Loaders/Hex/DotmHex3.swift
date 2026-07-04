import SwiftUI

/// Twin Diagonal Sweep — two diagonal bands sweep in opposite directions,
/// flashing the center on overlap. Mirrors upstream `dotm-hex-3.tsx`.
struct DotmHex3: View {
    var props = DotMatrixCommonProps(speed: 1.45, pattern: .full)

    private static let bandWidth: Double = 0.55
    private static let baseOp: Double = 0.08
    private static let highOp: Double = 0.96

    @inline(__always)
    private static func bandGlow(_ d: Double) -> Double {
        max(0, 1 - abs(d) / bandWidth)
    }

    var body: some View {
        DotMatrixHexBase(props: props, timing: .cycle(cycleMsBase: 1500)) { row, col, phase in
            let p = HexCell.point(row: row, col: col)
            let sweep = dmHexTriangularWave(phase) * 3.9 - 1.95
            let diagA = p.x * 0.86 + p.y * 0.5
            let diagB = p.x * -0.86 + p.y * 0.5
            let gateA = Self.bandGlow(diagA - sweep)
            let gateB = Self.bandGlow(diagB + sweep)
            let centerDistance = sqrt(p.x * p.x + p.y * p.y)
            let centerFlash = max(0, 1 - abs(sweep) / 0.68) * max(0, 1 - centerDistance / 1.9)
            let wake = 0.16 * max(0, 1 - abs(p.y - sweep * 0.22) / 1.2)
            return min(
                Self.highOp,
                Self.baseOp + gateA * 0.7 + gateB * 0.7 + centerFlash * 0.42 + wake
            )
        }
    }
}
