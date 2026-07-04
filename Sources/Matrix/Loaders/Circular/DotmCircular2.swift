import SwiftUI

/// 12-cell ring with `dmx-circular2-ring` keyframe.
struct DotmCircular2: View {
    var props = DotMatrixCommonProps(pattern: .full)

    // row-major indices matching the RING_PATH in the .tsx
    private static let RING_PATH: [Int] = [
        0 * 5 + 1,  // (0,1)
        0 * 5 + 2,  // (0,2)
        0 * 5 + 3,  // (0,3)
        1 * 5 + 4,  // (1,4)
        2 * 5 + 4,  // (2,4)
        3 * 5 + 4,  // (3,4)
        4 * 5 + 3,  // (4,3)
        4 * 5 + 2,  // (4,2)
        4 * 5 + 1,  // (4,1)
        3 * 5 + 0,  // (3,0)
        2 * 5 + 0,  // (2,0)
        1 * 5 + 0,  // (1,0)
    ]
    private static let LOOP_LEN: Int = 12
    private static let CENTER_OPACITY: Double = 0.18  // JS source-scale
    private static let BASE_OPACITY: Double = 0.08    // JS source-scale

    var body: some View {
        DotMatrixBase(props: props, bypassOpacityRemap: true) { ctx, now in
            let baseOp = props.opacityBase ?? DMKeyframes.DEFAULT_BASE
            let midOp = props.opacityMid ?? DMKeyframes.DEFAULT_MID
            let peakOp = props.opacityPeak ?? DMKeyframes.DEFAULT_PEAK
            // Helper: remap source-scale constants into user triplet.
            func remapped(_ v: Double) -> Double {
                remapOpacityToTriplet(
                    v, base: props.opacityBase, mid: props.opacityMid, peak: props.opacityPeak)
            }

            guard isWithinCircularMask(row: ctx.row, col: ctx.col) else { return 0 }

            let index = ctx.row * 5 + ctx.col
            guard let onRing = Self.RING_PATH.firstIndex(of: index) else {
                // Non-ring cell: center (2,2) gets CENTER, all others BASE (both source-scale).
                return ctx.row == 2 && ctx.col == 2
                    ? remapped(Self.CENTER_OPACITY)
                    : remapped(Self.BASE_OPACITY)
            }

            if ctx.reducedMotion || ctx.phase == .idle {
                let norm = Double(onRing) / Double(Self.LOOP_LEN - 1)
                return baseOp + norm * (peakOp - baseOp)
            }

            let cycleSec = 1.5
            let delaySec = Double(onRing) * 0.0833333333 * cycleSec
            let t = DMKeyframes.phaseWithDelay(now: now, cycleSec: cycleSec, delaySec: delaySec)
            return DMKeyframes.circular2Ring(t, base: baseOp, mid: midOp, peak: peakOp)
        }
    }
}
