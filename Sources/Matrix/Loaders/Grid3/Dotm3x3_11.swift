import SwiftUI

/// 3×3 glyph morph — seven 3×3 motifs (corners, cross, full, center, ring, X,
/// rails) that hold then morph into one another with a staggered smoothstep and
/// a breathing pulse during the hold. Fully JS-computed opacity (remapped).
/// Mirrors `dotm-3x3-11.tsx` (cycle 2700ms, speed 1.25).
struct Dotm3x3_11: View {
    var props = DotMatrixCommonProps(speed: 1.25, pattern: .full)

    private static let BASE_OPACITY = 0.06
    private static let PEAK_OPACITY = 0.88
    private static let CYCLE_MS_BASE: Double = 2700
    private static let HOLD_RATIO = 0.52
    private static let MORPH_RATIO = 0.34

    /// Distinct 3×3 motifs (index sets), in morph order.
    private static let GLYPH_PATTERNS: [Set<Int>] = [
        [0, 2, 6, 8],                 // corners
        [1, 3, 4, 5, 7],              // cross
        [0, 1, 2, 3, 4, 5, 6, 7, 8],  // full
        [4],                          // center
        [0, 1, 2, 3, 5, 6, 7, 8],     // ring / outline
        [0, 2, 4, 6, 8],              // X
        [1, 3, 5, 7],                 // rails
    ]

    private static func smoothstep(_ value: Double) -> Double {
        let t = min(1, max(0, value))
        return t * t * (3 - 2 * t)
    }

    private static func morphProgress(_ segmentPhase: Double, _ stagger: Double) -> Double {
        let morphStart = HOLD_RATIO
        let morphEnd = HOLD_RATIO + MORPH_RATIO
        if segmentPhase < morphStart + stagger * MORPH_RATIO { return 0 }
        if segmentPhase >= morphEnd { return 1 }
        let localSpan = morphEnd - morphStart
        let localPhase =
            (segmentPhase - morphStart - stagger * MORPH_RATIO) / (localSpan * (1 - stagger * 0.85))
        return smoothstep(localPhase)
    }

    var body: some View {
        DotMatrix3Base(props: props) { ctx, now in
            let active = ctx.phase != .idle && !ctx.reducedMotion
            let phase = cyclePhase(now: now, cycleMsBase: Self.CYCLE_MS_BASE, speed: 1, active: active)
            let count = Self.GLYPH_PATTERNS.count
            let scaled = phase * Double(count)
            let patternIndex = Int(floor(scaled)) % count
            let nextIndex = (patternIndex + 1) % count
            let segmentPhase = scaled - floor(scaled)
            let current = Self.GLYPH_PATTERNS[patternIndex]
            let next = Self.GLYPH_PATTERNS[nextIndex]

            let stagger = Double(ctx.row + ctx.col) / 4
            let morphT = Self.morphProgress(segmentPhase, stagger)
            var weight =
                (current.contains(ctx.index) ? 1.0 : 0) * (1 - morphT)
                + (next.contains(ctx.index) ? 1.0 : 0) * morphT

            if segmentPhase < Self.HOLD_RATIO && weight > 0.01 {
                let breathe = 0.78 + 0.22 * sin((segmentPhase / Self.HOLD_RATIO) * Double.pi)
                weight *= breathe
            }

            return Self.BASE_OPACITY + weight * (Self.PEAK_OPACITY - Self.BASE_OPACITY)
        }
    }
}
