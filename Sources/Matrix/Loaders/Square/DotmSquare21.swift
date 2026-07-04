import SwiftUI

/// Path-wave: snake. Drives `dmx-path` keyframe (=ripple) keyed by snake order.
struct DotmSquare21: View {
    var props = DotMatrixCommonProps(pattern: .full)
    var body: some View {
        PathWaveBase(
            props: props,
            normFn: { idx, _, _ in DotMatrixGridPaths.snakePathNormFromIndex(idx) }
        )
    }
}

/// Shared `path-wave-factory` analogue: `dmx-path` keyframe (= ripple), delay = norm * 0.2333.
struct PathWaveBase: View {
    let props: DotMatrixCommonProps
    let normFn: (Int, Int, Int) -> Double  // (index, row, col) -> norm

    var body: some View {
        DotMatrixBase(props: props, bypassOpacityRemap: true) { ctx, now in
            let baseOp = props.opacityBase ?? DMKeyframes.DEFAULT_BASE
            let peakOp = props.opacityPeak ?? DMKeyframes.DEFAULT_PEAK
            let path = normFn(ctx.index, ctx.row, ctx.col)
            if ctx.reducedMotion || ctx.phase == .idle {
                return baseOp + path * (peakOp - baseOp)
            }
            let cycleSec = 1.5
            let delay = path * 0.2333 * cycleSec
            let t = DMKeyframes.phaseWithDelay(now: now, cycleSec: cycleSec, delaySec: delay)
            return DMKeyframes.ripple(t, base: baseOp, peak: peakOp)
        }
    }
}
