import SwiftUI

/// 4 geometric masks with stepped cycle. Sequence: [0,1,2,3,2,1], 1700ms.
struct DotmSquare14: View {
    var props = DotMatrixCommonProps(pattern: .full)

    private static let BASE_OPACITY: Double = 0.08
    private static let MID_OPACITY: Double = 0.52
    private static let PEAK_OPACITY: Double = 1

    private static let FRAME_MASKS: [String] = [
        "x...x" + ".x.x." + "..o.." + ".x.x." + "x...x",  // Diagonal star
        "..x.." + ".oxo." + "xooox" + ".oxo." + "..x..",  // Diamond bloom
        ".x.x." + "x.o.x" + "..o.." + "x.o.x" + ".x.x.", // Petal ring
        "x.x.x" + ".o.o." + "x.o.x" + ".o.o." + "x.x.x"  // Crossed lattice
    ]

    private static let FRAME_SEQUENCE: [Int] = [0, 1, 2, 3, 2, 1]

    var body: some View {
        let seqLen = Self.FRAME_SEQUENCE.count
        DotMatrixBase(props: props) { ctx, now in
            let step = steppedCycle(now: now, cycleMsBase: 1700, steps: seqLen, speed: 1, active: ctx.phase != .idle && !ctx.reducedMotion)
            let frameIndex = Self.FRAME_SEQUENCE[step]
            let mask = Self.FRAME_MASKS[frameIndex]
            let charIdx = rowMajorIndex(ctx.row, ctx.col)
            let ch = mask.count > charIdx ? mask[mask.index(mask.startIndex, offsetBy: charIdx)] : Character(".")
            switch ch {
            case "x": return Self.PEAK_OPACITY
            case "o": return Self.MID_OPACITY
            default:  return Self.BASE_OPACITY
            }
        }
    }
}
