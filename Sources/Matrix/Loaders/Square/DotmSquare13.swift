import SwiftUI

/// 8 compass-direction masks (N/NE/E/SE/S/SW/W/NW), each shown twice (16 steps), 1550ms.
struct DotmSquare13: View {
    var props = DotMatrixCommonProps(pattern: .full)

    private static let BASE_OPACITY: Double = 0.08
    private static let ON_OPACITY: Double = 0.56
    private static let PEAK_OPACITY: Double = 1

    private static let FRAME_MASKS: [String] = [
        "..x.." + "..x.." + "..o.." + "....." + ".....",   // N
        "....x" + "...x." + "..o.." + "....." + ".....",   // NE
        "....." + "....." + "..oxx" + "....." + ".....",   // E
        "....." + "....." + "..o.." + "...x." + "....x",  // SE
        "....." + "....." + "..o.." + "..x.." + "..x..",  // S
        "....." + "....." + "..o.." + ".x..." + "x....",  // SW
        "....." + "....." + "xxo.." + "....." + ".....",   // W
        "x...." + ".x..." + "..o.." + "....." + ".....",   // NW
    ]

    private static let FRAME_SEQUENCE: [Int] = [0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7]

    var body: some View {
        let seqLen = Self.FRAME_SEQUENCE.count
        DotMatrixBase(props: props) { ctx, now in
            let step = steppedCycle(now: now, cycleMsBase: 1550, steps: seqLen, speed: 1, active: ctx.phase != .idle && !ctx.reducedMotion)
            let frameIndex = Self.FRAME_SEQUENCE[step]
            let mask = Self.FRAME_MASKS[frameIndex]
            let charIdx = rowMajorIndex(ctx.row, ctx.col)
            let ch = mask.count > charIdx ? mask[mask.index(mask.startIndex, offsetBy: charIdx)] : Character(".")
            switch ch {
            case "x": return Self.PEAK_OPACITY
            case "o": return Self.ON_OPACITY
            default:  return Self.BASE_OPACITY
            }
        }
    }
}
