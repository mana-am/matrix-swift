import SwiftUI

/// Reusable 3×3 loader factories. Mirror `core/diagonal-wave-3-factory.tsx` and
/// `core/glyph-spin-3-factory.tsx`. The per-variant loaders (`Dotm3x3_2..5`,
/// `Dotm3x3_16/18..21`) are thin wrappers around these.

// MARK: - shared triplet helpers

/// The effective `(base, mid, peak)` the CSS keyframe vars resolve to for a 3×3
/// loader: `--dmx-opacity-base` defaults to 0.06 (set by `DotMatrix3Base`),
/// `--dmx-opacity-mid` / `-peak` fall back to the `.dmx-root` defaults.
@inline(__always)
func dm3UserTriplet(_ props: DotMatrixCommonProps) -> (base: Double, mid: Double, peak: Double) {
    (
        props.opacityBase ?? 0.06,
        props.opacityMid ?? DMKeyframes.DEFAULT_MID,
        props.opacityPeak ?? DMKeyframes.DEFAULT_PEAK
    )
}

// MARK: - Diagonal wave (dmx-path-3 → dmx-ripple-3 keyframe)

/// `createDiagonalWave3Component` — a diagonal wavefront that pulses each dot in
/// turn along one of four directions. Animated dots run `dmx-ripple-3`
/// (`dur ×0.68`, per-dot `delay = path ×0.19 ×cycle`); idle previews the path
/// position via a base→mid→peak blend.
struct DiagonalWave3Loader: View {
    var props = DotMatrixCommonProps(speed: 1.15, pattern: .full)
    let direction: DotMatrix3GridPaths.DiagonalDirection

    var body: some View {
        DotMatrix3Base(props: props, bypassOpacityRemap: true) { ctx, now in
            let t3 = dm3UserTriplet(props)
            let path = DotMatrix3GridPaths.diagonalNorm(ctx.index, direction)
            if ctx.reducedMotion || ctx.phase == .idle {
                return remapOpacityToTriplet(
                    DotMatrix3GridPaths.pathOpacityFromNorm(path),
                    base: props.opacityBase ?? 0.06, mid: props.opacityMid, peak: props.opacityPeak)
            }
            let cycleSec = DM3Keyframes.CYCLE_SEC * 0.68
            let delay = path * 0.19 * DM3Keyframes.CYCLE_SEC
            let t = DMKeyframes.phaseWithDelay(now: now, cycleSec: cycleSec, delaySec: delay)
            return DM3Keyframes.ripple3(t, base: t3.base, mid: t3.mid, peak: t3.peak)
        }
    }
}

// MARK: - Glyph spin (rotate a 3×3 0/1 glyph in 90° steps)

/// `createGlyphSpin3Component` — a 3×3 0/1 glyph rotated in four 90° steps with
/// smoothstep cross-fades between rotations. Opacity is JS-computed (0.09…0.88)
/// and remapped by the base.
struct GlyphSpin3Loader: View {
    var props = DotMatrixCommonProps(speed: 1, pattern: .full)
    /// Row-major 0/1 glyph, length 9.
    let glyph: [Int]

    private static let BASE_OPACITY = 0.09
    private static let PEAK_OPACITY = 0.88
    private static let STEP_MS: Double = 180
    private static let ROTATION_STEPS = 4
    private static let CYCLE_MS_BASE = 180.0 * 4  // STEP_MS * ROTATION_STEPS

    /// Rotate a 3×3 pattern clockwise by `turns` 90° steps. Mirrors `rotate3x3`.
    static func rotate(_ pattern: [Int], turns: Int) -> [Int] {
        let steps = ((turns % ROTATION_STEPS) + ROTATION_STEPS) % ROTATION_STEPS
        if steps == 0 { return pattern }
        var out = pattern
        for _ in 0..<steps {
            var next = [Int](repeating: 0, count: 9)
            for i in 0..<9 {
                let r = i / 3
                let c = i % 3
                let nr = c
                let nc = 2 - r
                next[nr * 3 + nc] = out[i]
            }
            out = next
        }
        return out
    }

    private static func smoothstep(_ value: Double) -> Double {
        let t = min(1, max(0, value))
        return t * t * (3 - 2 * t)
    }

    private static func opacity(_ current: [Int], _ next: [Int], _ index: Int, _ t: Double) -> Double {
        let cur = index < current.count ? Double(current[index]) : 0
        let nxt = index < next.count ? Double(next[index]) : 0
        let weight = cur * (1 - t) + nxt * t
        return BASE_OPACITY + weight * (PEAK_OPACITY - BASE_OPACITY)
    }

    var body: some View {
        DotMatrix3Base(props: props) { ctx, now in
            let active = ctx.phase != .idle && !ctx.reducedMotion
            if !active {
                return Self.opacity(glyph, glyph, ctx.index, 0)
            }
            let phase = cyclePhase(now: now, cycleMsBase: Self.CYCLE_MS_BASE, speed: 1, active: true)
            let scaled = phase * Double(Self.ROTATION_STEPS)
            let turns = Int(floor(scaled)) % Self.ROTATION_STEPS
            let segmentT = Self.smoothstep(scaled - floor(scaled))
            let current = Self.rotate(glyph, turns: turns)
            let next = Self.rotate(glyph, turns: turns + 1)
            return Self.opacity(current, next, ctx.index, segmentT)
        }
    }
}
