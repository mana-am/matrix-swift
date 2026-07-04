import Foundation

/// 3×3-specific keyframe ports + timing constants. Mirrors the `.dmx-*-3`
/// classes and the `dmx-ripple-3` keyframe in `loaders/styles.css`.
///
/// The other 3×3 classes reuse keyframes already ported for the 5×5 grid
/// (`DMKeyframes.spiralSnake` / `.centerOriginRipple` / `.rippleEcho`), so only
/// `dmx-ripple-3` needs a fresh port here.
enum DM3Keyframes {

    /// `.dmx-root.dmx-matrix-3 { --dmx-cycle: 1500ms }` — the base cycle every
    /// 3×3 class multiplies by its own duration factor.
    static let CYCLE_SEC: Double = 1.5

    /// `@keyframes dmx-ripple-3` — a sharp pulse that fires in the first 20% of
    /// the cycle then rests at base. Most callers use `cubic-bezier(0.42, 0,
    /// 0.58, 1)` easing (same as the 5×5 `dmx-ripple`); `.dmx-distance-ripple-3`
    /// uses `ease-out` = `cubic-bezier(0, 0, 0.58, 1)`, selected via `easeOut`.
    static func ripple3(
        _ t: Double,
        base: Double = DMKeyframes.DEFAULT_BASE,
        mid: Double = DMKeyframes.DEFAULT_MID,
        peak: Double = DMKeyframes.DEFAULT_PEAK,
        easeOut: Bool = false
    ) -> Double {
        let eased = easeOut
            ? DMKeyframes.cubicBezier(t, 0, 0, 0.58, 1)
            : DMKeyframes.cubicBezier(t, 0.42, 0, 0.58, 1)
        let midBase = 0.62 * mid + 0.38 * base
        let peakMid = 0.35 * peak + 0.65 * mid
        return DMKeyframes.interpStops(
            eased,
            [
                (0, base),
                (3, midBase),
                (6, peakMid),
                (10, peak),
                (14, peakMid),
                (17, midBase),
                (20, base),
                (100, base),
            ])
    }
}
