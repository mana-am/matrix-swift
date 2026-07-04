import SwiftUI

/// Fill wave + flash + clear — stepped 11-frame sequence, 1900ms.
struct DotmSquare7: View {
    var props = DotMatrixCommonProps(pattern: .full)

    private static let BASE_OPACITY: Double = 0.08
    private static let SETTLED_OPACITY: Double = 0.42
    private static let ACTIVE_OPACITY: Double = 1
    private static let CLEAR_OPACITY: Double = 0.88
    private static let IDLE_STEP: Int = 10

    private static let FRAME_MASKS: [String] = [
        "....." + "....." + "....." + "....." + "ooooo",
        "....." + "....." + "....." + "ooooo" + "ooooo",
        "....." + "....." + "ooooo" + "ooooo" + "ooooo",
        "....." + "ooooo" + "ooooo" + "ooooo" + "ooooo",
        "ooooo" + "ooooo" + "ooooo" + "ooooo" + "ooooo",
        "ccccc" + "ccccc" + "ccccc" + "ccccc" + "ccccc",
        "....." + "....." + "....." + "....." + ".....",
        "ccccc" + "ccccc" + "ccccc" + "ccccc" + "ccccc",
        "....." + "....." + "....." + "....." + ".....",
        "....." + "....." + "....." + "....." + "....."
    ]

    private static let FRAME_SEQUENCE: [Int] = [0, 1, 2, 3, 4, 4, 5, 6, 7, 8, 9]

    var body: some View {
        let seqLen = Self.FRAME_SEQUENCE.count
        let idleStep = min(Self.IDLE_STEP, seqLen - 1)
        DotMatrixBase(props: props) { ctx, now in
            let step = steppedCycle(
                now: now, cycleMsBase: 1900, steps: seqLen, speed: 1,
                active: !ctx.reducedMotion && ctx.phase != .idle,
                idleStep: idleStep)
            let frame = Self.FRAME_SEQUENCE[step]
            let mask = Self.FRAME_MASKS[frame]
            let charIdx = rowMajorIndex(ctx.row, ctx.col)
            let ch = mask.count > charIdx ? mask[mask.index(mask.startIndex, offsetBy: charIdx)] : Character(".")
            switch ch {
            case "x": return Self.ACTIVE_OPACITY
            case "o": return Self.SETTLED_OPACITY
            case "c": return Self.CLEAR_OPACITY
            default:  return Self.BASE_OPACITY
            }
        }
    }
}
