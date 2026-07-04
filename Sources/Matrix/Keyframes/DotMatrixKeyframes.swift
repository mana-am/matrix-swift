import Foundation

/// CSS @keyframes ports. Each function takes `t ∈ [0,1)` plus the user's opacity triplet
/// (default `0.16 / 0.32 / 1.0` per `.dmx-root` CSS) and returns the dot's opacity at that moment.
///
/// All percent stops match `loaders/styles.css` exactly. Stops between adjacent steps are
/// interpolated linearly (CSS default) unless a `steps(N, end)` timing was declared, in which
/// case we snap to the lower percent.
enum DMKeyframes {

    /// Default base/mid/peak when none provided (mirrors `.dmx-root` CSS variable defaults).
    static let DEFAULT_BASE: Double = 0.16
    static let DEFAULT_MID: Double = 0.32
    static let DEFAULT_PEAK: Double = 1.0

    // MARK: - linear stop interpolation

    /// Each stop is `(percent ∈ [0,100], value)`. Stops are sorted ascending. Two stops with
    /// the same percent encode an instant jump.
    static func interpStops(_ t: Double, _ stops: [(Double, Double)]) -> Double {
        let p = max(0, min(100, t * 100))
        if stops.isEmpty { return 0 }
        if p <= stops.first!.0 { return stops.first!.1 }
        if p >= stops.last!.0 { return stops.last!.1 }
        for i in 0..<(stops.count - 1) {
            let (p0, v0) = stops[i]
            let (p1, v1) = stops[i + 1]
            if p >= p0 && p <= p1 {
                if p1 == p0 { return v1 }
                let u = (p - p0) / (p1 - p0)
                return v0 + (v1 - v0) * u
            }
        }
        return stops.last!.1
    }

    /// `steps(N, end)`: the value snaps when crossing each `1/N` boundary, holding the
    /// previous step's value otherwise. The keyframe stops are evaluated at the snapped
    /// percent (the "end" of each step is the value that's held).
    static func interpSteps(_ t: Double, count: Int, _ stops: [(Double, Double)]) -> Double {
        guard count > 0 else { return 0 }
        let stepIdx = min(count - 1, max(0, Int(floor(t * Double(count)))))
        let snapped = Double(stepIdx) / Double(count)
        return interpStops(snapped, stops)
    }

    // MARK: - cubic bezier (used by dmx-ripple, dmx-path)

    /// Approximate the y of a cubic-bezier curve `cubic-bezier(x1,y1,x2,y2)` at parameter `t`.
    /// We solve for the bezier's `t` whose x equals input progress (Newton iteration), then
    /// return the y at that t.
    static func cubicBezier(
        _ progress: Double, _ x1: Double, _ y1: Double, _ x2: Double, _ y2: Double
    ) -> Double {
        // Cubic bezier x(t), y(t) with P0=(0,0), P3=(1,1)
        func bezier(_ t: Double, _ a: Double, _ b: Double) -> Double {
            let oneMinus = 1 - t
            return 3 * oneMinus * oneMinus * t * a + 3 * oneMinus * t * t * b + t * t * t
        }
        // Bisect-friendly Newton: 8 iterations are enough for ~0.001 accuracy.
        var t = progress
        for _ in 0..<8 {
            let x = bezier(t, x1, x2) - progress
            let dx = 3 * (1 - t) * (1 - t) * x1 + 6 * (1 - t) * t * (x2 - x1) + 3 * t * t * (1 - x2)
            if abs(dx) < 1e-6 { break }
            t -= x / dx
            t = max(0, min(1, t))
        }
        return bezier(t, y1, y2)
    }

    // MARK: - dmx-ripple

    static func ripple(_ t: Double, base: Double = DEFAULT_BASE, peak: Double = DEFAULT_PEAK)
        -> Double
    {
        // 0/100 → base, 50 → peak, with cubic-bezier(0.42,0,0.58,1) over the cycle
        let eased = cubicBezier(t, 0.42, 0, 0.58, 1)
        return interpStops(eased, [(0, base), (50, peak), (100, base)])
    }

    // MARK: - dmx-ripple-echo

    static func rippleEcho(
        _ t: Double, base: Double = DEFAULT_BASE, mid: Double = DEFAULT_MID,
        peak: Double = DEFAULT_PEAK
    ) -> Double {
        // ease-in-out
        let eased = cubicBezier(t, 0.42, 0, 0.58, 1)
        return interpStops(
            eased,
            [
                (0, 0.625 * base),
                (28, 0.98 * peak),
                (56, mid),
                (78, 0.68 * peak + 0.32 * mid),
                (100, 0.625 * base),
            ])
    }

    // MARK: - dmx-center-origin-ripple

    static func centerOriginRipple(
        _ t: Double, base: Double = DEFAULT_BASE, mid: Double = DEFAULT_MID,
        peak: Double = DEFAULT_PEAK
    ) -> Double {
        let eased = cubicBezier(t, 0.42, 0, 0.58, 1)
        let blendBaseMid = 0.5 * (base + mid)
        return interpStops(
            eased,
            [
                (0, 0.625 * base),
                (34, peak),
                (60, blendBaseMid),
                (100, 0.625 * base),
            ])
    }

    // MARK: - dmx-collapse  (forwards / ease-in)

    static func collapse(
        _ t: Double, base: Double = DEFAULT_BASE, mid: Double = DEFAULT_MID,
        peak: Double = DEFAULT_PEAK
    ) -> Double {
        // ease-in approximated as cubic-bezier(0.42, 0, 1, 1)
        let eased = cubicBezier(min(1, t), 0.42, 0, 1, 1)
        return interpStops(eased, [(0, 0.95 * peak + 0.05 * mid), (100, 0.375 * base)])
    }

    // MARK: - dmx-hover-ripple

    static func hoverRipple(
        _ t: Double, base: Double = DEFAULT_BASE, peak: Double = DEFAULT_PEAK
    ) -> Double {
        let eased = cubicBezier(t, 0.42, 0, 0.58, 1)
        return interpStops(eased, [(0, 0.5 * base), (45, peak), (100, base)])
    }

    // MARK: - dmx-diagonal-alt-sweep

    static func diagonalAltSweep(
        _ t: Double, base: Double = DEFAULT_BASE, peak: Double = DEFAULT_PEAK
    ) -> Double {
        // linear timing
        return interpStops(
            t,
            [
                (0, 0.5 * base),
                (14, peak),
                (30, 0.75 * base),
                (100, 0.5 * base),
            ])
    }

    // MARK: - dmx-spiral-snake (linear)

    static func spiralSnake(
        _ t: Double, base: Double = DEFAULT_BASE, mid: Double = DEFAULT_MID,
        peak: Double = DEFAULT_PEAK
    ) -> Double {
        return interpStops(
            t,
            [
                (0, 0.5 * base),
                (8, peak),
                (16, 0.5 * peak + 0.4 * mid + 0.1 * base),
                (24, 0.25 * peak + 0.45 * mid + 0.3 * base),
                (32, 0.5 * mid + 0.5 * base),
                (40, 0.75 * base),
                (100, 0.5 * base),
            ])
    }

    // MARK: - dmx-diagonal-snake (linear)

    static func diagonalSnake(
        _ t: Double, base: Double = DEFAULT_BASE, mid: Double = DEFAULT_MID,
        peak: Double = DEFAULT_PEAK
    ) -> Double {
        // Same stops as spiral-snake per styles.css
        return spiralSnake(t, base: base, mid: mid, peak: peak)
    }

    // MARK: - dmx-ring-snake (linear, used by outer + middle)

    static func ringSnake(
        _ t: Double, base: Double = DEFAULT_BASE, mid: Double = DEFAULT_MID,
        peak: Double = DEFAULT_PEAK
    ) -> Double {
        return interpStops(
            t,
            [
                (0, 0.5 * base),
                (10, peak),
                (20, 0.45 * peak + 0.45 * mid + 0.1 * base),
                (30, 0.2 * peak + 0.4 * mid + 0.4 * base),
                (40, 0.875 * base),
                (100, 0.5 * base),
            ])
    }

    // MARK: - dmx-square9-d1..d6 (steps(52, end))

    private static let SQUARE9_STEPS = 52

    private static func square9Stops(_ pairs: [(Double, Double)]) -> [(Double, Double)] {
        // The CSS form is "0%, X% { base }; X%, Y% { peak }; ..." where the "from"/"to"
        // pairs encode hold ranges. We map each percent to its on/off state directly.
        return pairs
    }

    static func square9D1(
        _ t: Double, base: Double = DEFAULT_BASE, peak: Double = DEFAULT_PEAK
    ) -> Double {
        // From styles.css verbatim: dmx-square9-d1
        let stops: [(Double, Double)] = [
            (0, base), (3.846154, base), (3.846154, peak), (30.769231, peak),
            (30.769231, base), (46.153846, base), (46.153846, peak), (50, peak),
            (50, base), (53.846154, base), (53.846154, peak), (57.692308, peak),
            (57.692308, base), (65.384615, base), (65.384615, peak), (71.153846, peak),
            (71.153846, base), (80.769231, base), (80.769231, peak), (84.615385, peak),
            (84.615385, base), (88.461538, base), (88.461538, peak), (92.307692, peak),
            (92.307692, base), (100, base),
        ]
        return interpSteps(t, count: SQUARE9_STEPS, stops)
    }

    static func square9D2(
        _ t: Double, base: Double = DEFAULT_BASE, peak: Double = DEFAULT_PEAK
    ) -> Double {
        let stops: [(Double, Double)] = [
            (0, base), (5.769231, base), (5.769231, peak), (25, peak),
            (25, base), (30.769231, base), (30.769231, peak), (36.538462, peak),
            (36.538462, base), (50, base), (50, peak), (53.846154, peak),
            (53.846154, base), (57.692308, base), (57.692308, peak), (61.538462, peak),
            (61.538462, base), (65.384615, base), (65.384615, peak), (76.923077, peak),
            (76.923077, base), (80.769231, base), (80.769231, peak), (84.615385, peak),
            (84.615385, base), (88.461538, base), (88.461538, peak), (92.307692, peak),
            (92.307692, base), (100, base),
        ]
        return interpSteps(t, count: SQUARE9_STEPS, stops)
    }

    static func square9D3(
        _ t: Double, base: Double = DEFAULT_BASE, peak: Double = DEFAULT_PEAK
    ) -> Double {
        let stops: [(Double, Double)] = [
            (0, base), (7.692308, base), (7.692308, peak), (25, peak),
            (25, base), (36.538462, base), (36.538462, peak), (42.307692, peak),
            (42.307692, base), (46.153846, base), (46.153846, peak), (50, peak),
            (50, base), (53.846154, base), (53.846154, peak), (57.692308, peak),
            (57.692308, base), (71.153846, base), (71.153846, peak), (76.923077, peak),
            (76.923077, base), (80.769231, base), (80.769231, peak), (84.615385, peak),
            (84.615385, base), (88.461538, base), (88.461538, peak), (92.307692, peak),
            (92.307692, base), (100, base),
        ]
        return interpSteps(t, count: SQUARE9_STEPS, stops)
    }

    static func square9D4(
        _ t: Double, base: Double = DEFAULT_BASE, peak: Double = DEFAULT_PEAK
    ) -> Double {
        let stops: [(Double, Double)] = [
            (0, base), (13.461538, base), (13.461538, peak), (30.769231, peak),
            (30.769231, base), (50, base), (50, peak), (53.846154, peak),
            (53.846154, base), (57.692308, base), (57.692308, peak), (61.538462, peak),
            (61.538462, base), (65.384615, base), (65.384615, peak), (71.153846, peak),
            (71.153846, base), (84.615385, base), (84.615385, peak), (88.461538, peak),
            (88.461538, base), (92.307692, base), (92.307692, peak), (96.153846, peak),
            (96.153846, base), (100, base),
        ]
        return interpSteps(t, count: SQUARE9_STEPS, stops)
    }

    static func square9D5(
        _ t: Double, base: Double = DEFAULT_BASE, peak: Double = DEFAULT_PEAK
    ) -> Double {
        let stops: [(Double, Double)] = [
            (0, base), (15.384615, base), (15.384615, peak), (25, peak),
            (25, base), (30.769231, base), (30.769231, peak), (36.538462, peak),
            (36.538462, base), (46.153846, base), (46.153846, peak), (50, peak),
            (50, base), (53.846154, base), (53.846154, peak), (57.692308, peak),
            (57.692308, base), (65.384615, base), (65.384615, peak), (76.923077, peak),
            (76.923077, base), (84.615385, base), (84.615385, peak), (88.461538, peak),
            (88.461538, base), (92.307692, base), (92.307692, peak), (96.153846, peak),
            (96.153846, base), (100, base),
        ]
        return interpSteps(t, count: SQUARE9_STEPS, stops)
    }

    static func square9D6(
        _ t: Double, base: Double = DEFAULT_BASE, peak: Double = DEFAULT_PEAK
    ) -> Double {
        let stops: [(Double, Double)] = [
            (0, base), (17.307692, base), (17.307692, peak), (25, peak),
            (25, base), (36.538462, base), (36.538462, peak), (42.307692, peak),
            (42.307692, base), (50, base), (50, peak), (53.846154, peak),
            (53.846154, base), (57.692308, base), (57.692308, peak), (61.538462, peak),
            (61.538462, base), (71.153846, base), (71.153846, peak), (76.923077, peak),
            (76.923077, base), (84.615385, base), (84.615385, peak), (88.461538, peak),
            (88.461538, base), (92.307692, base), (92.307692, peak), (96.153846, peak),
            (96.153846, base), (100, base),
        ]
        return interpSteps(t, count: SQUARE9_STEPS, stops)
    }

    // MARK: - dmx-square6-col-snake (steps(5, end))

    static func square6ColSnake(
        _ t: Double, base: Double = DEFAULT_BASE, mid: Double = DEFAULT_MID,
        peak: Double = DEFAULT_PEAK
    ) -> Double {
        let stops: [(Double, Double)] = [
            (0, 0.6 * peak + 0.25 * mid + 0.15 * base),
            (20, 0.6 * peak + 0.25 * mid + 0.15 * base),
            (20, 0.3 * peak + 0.5 * mid + 0.2 * base),
            (40, 0.3 * peak + 0.5 * mid + 0.2 * base),
            (40, 0.6 * mid + 0.4 * base),
            (60, 0.6 * mid + 0.4 * base),
            (60, 0.2 * mid + 0.8 * base),
            (80, 0.2 * mid + 0.8 * base),
            (80, 0.625 * base),
            (100, 0.625 * base),
        ]
        return interpSteps(t, count: 5, stops)
    }

    // MARK: - dmx-circular2-ring (steps(12, end))

    static func circular2Ring(
        _ t: Double, base: Double = DEFAULT_BASE, mid: Double = DEFAULT_MID,
        peak: Double = DEFAULT_PEAK
    ) -> Double {
        let blendPeakMid = 0.6 * peak + 0.4 * mid
        let blendMidBase = 0.5 * mid + 0.5 * base
        let lowMidBase = 0.3 * mid + 0.7 * base
        let stops: [(Double, Double)] = [
            (0, peak), (8.333333, peak),
            (8.333333, blendPeakMid), (16.666667, blendPeakMid),
            (16.666667, blendMidBase), (25, blendMidBase),
            (25, lowMidBase), (33.333333, lowMidBase),
            (33.333333, peak), (41.666667, peak),
            (41.666667, blendPeakMid), (50, blendPeakMid),
            (50, blendMidBase), (58.333333, blendMidBase),
            (58.333333, lowMidBase), (66.666667, lowMidBase),
            (66.666667, peak), (75, peak),
            (75, blendPeakMid), (83.333333, blendPeakMid),
            (83.333333, blendMidBase), (91.666667, blendMidBase),
            (91.666667, lowMidBase), (100, lowMidBase),
        ]
        return interpSteps(t, count: 12, stops)
    }

    // MARK: - heartbeat (lub-dub)

    /// Two-pulse pattern: a strong "lub" then a softer "dub", followed by a long rest.
    /// Stops chosen to feel like a slowed real heartbeat (~50 BPM at cycleSec = 1.2).
    static func heartbeat(
        _ t: Double, base: Double = DEFAULT_BASE, mid: Double = DEFAULT_MID,
        peak: Double = DEFAULT_PEAK
    ) -> Double {
        // Linear interpolation — the staccato itself comes from the stop placement.
        return interpStops(
            t,
            [
                (0, base),
                (8, peak),                 // lub (fast rise)
                (16, 0.4 * peak + 0.6 * mid),
                (22, 0.5 * (mid + base)),  // brief settle
                (28, 0.85 * peak),         // dub (smaller second beat)
                (38, mid),
                (52, base),
                (100, base),               // long rest
            ])
    }

    // MARK: - ink-bleed

    /// A drop of ink hitting paper: fast saturated rise, slow asymmetric tail as it spreads.
    /// Use with a per-cell delay proportional to Manhattan distance from the origin.
    static func inkBleed(
        _ t: Double, base: Double = DEFAULT_BASE, mid: Double = DEFAULT_MID,
        peak: Double = DEFAULT_PEAK
    ) -> Double {
        // ease-out curve: fast at the start, drawn-out tail.
        let eased = cubicBezier(t, 0.16, 1, 0.3, 1)
        return interpStops(
            eased,
            [
                (0, 0.4 * base),
                (12, peak),
                (28, 0.7 * peak + 0.3 * mid),
                (52, mid),
                (78, 0.7 * base + 0.3 * mid),
                (100, 0.4 * base),
            ])
    }

    // MARK: - token-fall

    /// A token "drops" into its cell from above: invisible briefly, snaps to peak, then settles
    /// to mid where it stays. Combined with a per-cell stagger this looks like text being
    /// composed top-to-bottom, left-to-right.
    static func tokenFall(
        _ t: Double, base: Double = DEFAULT_BASE, mid: Double = DEFAULT_MID,
        peak: Double = DEFAULT_PEAK
    ) -> Double {
        return interpStops(
            t,
            [
                (0, 0),
                (4, 0),                   // hidden until the wave reaches us
                (10, peak),                // pop in
                (22, 0.6 * peak + 0.4 * mid),
                (35, mid),                 // settle
                (90, mid),                 // hold for most of the cycle
                (100, 0.5 * base),         // brief fade before next loop
            ])
    }

    // MARK: - breathing (slow inhale / exhale)

    /// Sinusoidal breathing — calmest of the lot. Use cycleSec ≈ 4 for a relaxed rhythm.
    static func breathing(
        _ t: Double, base: Double = DEFAULT_BASE, peak: Double = DEFAULT_PEAK
    ) -> Double {
        // Smooth sin wave from base to peak.
        let s = (1 - cos(2 * .pi * t)) / 2  // 0 → 1 → 0 across the cycle
        return base + (peak - base) * s
    }

    // MARK: - shimmer (skeleton-loading sweep)

    /// A bright "highlight" sweeping across the cell. The caller supplies a per-cell `phase`
    /// in [0,1) (e.g. anti-diagonal slice norm) and `t` is the global cycle phase. Returns
    /// peak when (t-phase)%1 is near 0.15, base elsewhere — a classic iOS skeleton shimmer.
    static func shimmer(
        _ t: Double, cellPhase: Double,
        base: Double = DEFAULT_BASE, peak: Double = DEFAULT_PEAK
    ) -> Double {
        let p = (t - cellPhase + 1).truncatingRemainder(dividingBy: 1)
        // bright lobe near p=0.15, ~25% wide
        let center = 0.15
        let halfWidth = 0.18
        let dist = abs(p - center)
        if dist >= halfWidth { return base }
        let u = 1 - dist / halfWidth        // 1 at center, 0 at edges
        let eased = u * u * (3 - 2 * u)     // smoothstep
        return base + (peak - base) * eased
    }

    // MARK: - confetti pop

    /// A single shot: invisible → fast pop to peak → exponential fade. Use a per-cell delay
    /// so neighbors fire slightly after the origin.
    static func confettiPop(
        _ t: Double, base: Double = DEFAULT_BASE, mid: Double = DEFAULT_MID,
        peak: Double = DEFAULT_PEAK
    ) -> Double {
        return interpStops(
            t,
            [
                (0, 0),
                (5, 0),
                (12, peak),
                (18, 0.8 * peak + 0.2 * mid),
                (35, mid),
                (60, 0.5 * (mid + base)),
                (85, base),
                (100, base),
            ])
    }

    // MARK: - pulse-ring fade (each ring decays independently after the center pulses)

    /// Resolves opacity given the cell's ring index (0…4) and the cycle phase. Outer rings
    /// fire later and decay slower, giving a "lingering echo" effect distinct from
    /// `centerOriginRipple` (which loops everything at once).
    static func pulseRing(
        _ t: Double, ring: Int, maxRing: Int,
        base: Double = DEFAULT_BASE, mid: Double = DEFAULT_MID, peak: Double = DEFAULT_PEAK
    ) -> Double {
        let ringNorm = maxRing > 0 ? Double(ring) / Double(maxRing) : 0
        // Ring r fires at phase = ringNorm * 0.35; lingers for 0.4 + ringNorm*0.3.
        let firePhase = ringNorm * 0.35
        let lingerSpan = 0.4 + ringNorm * 0.3
        let local = (t - firePhase + 1).truncatingRemainder(dividingBy: 1)
        if local > lingerSpan {
            return base
        }
        let u = local / lingerSpan
        // Snap rise (first 8% of lingerSpan) to peak, then ease out to base.
        if u < 0.08 {
            return base + (peak - base) * (u / 0.08)
        }
        let decay = (u - 0.08) / 0.92
        let eased = 1 - decay * decay  // ease-out quadratic
        return base + (mid + (peak - mid) * eased - base) * eased
    }

    // MARK: - delay computation helpers

    /// Compute progress `[0,1)` accounting for an animation-delay `delaySec` on a `cycleSec` loop.
    @inline(__always)
    static func phaseWithDelay(now: TimeInterval, cycleSec: Double, delaySec: Double) -> Double {
        guard cycleSec > 0 else { return 0 }
        let raw = (now - delaySec).truncatingRemainder(dividingBy: cycleSec)
        let positive = (raw + cycleSec).truncatingRemainder(dividingBy: cycleSec)
        return positive / cycleSec
    }
}
