import SwiftUI

/// Per-dot bloom/halo math, mirroring upstream `loaders/core/dmx-dot-bloom.ts`
/// and `opacity-triplet.ts`. Returned `level` is `0…1`; `applyBloom(_:)` turns
/// it into a SwiftUI `.shadow(...)` overlay sized off the dot itself.
enum DotMatrixBloom {

    /// Remapped opacity threshold above which a cell starts glowing.
    static let bloomMin: Double = 0.6

    /// `0…1` bloom level for a remapped opacity. Linear ramp from `bloomMin`
    /// (level 0, glow just appears) to 1.0 (level 1, full glow).
    @inline(__always)
    static func bloomLevel(remappedOpacity r: Double) -> Double {
        let v = (r - bloomMin) / (1 - bloomMin)
        return max(0, min(1, v))
    }

    /// True when `bloom` is enabled AND the cell sits above the threshold.
    @inline(__always)
    static func qualifiesForBloom(remappedOpacity r: Double) -> Bool {
        r >= bloomMin
    }

    /// `0…1` halo, clamped from the user-supplied `halo` prop.
    @inline(__always)
    static func clampHalo(_ halo: Double) -> Double {
        guard halo.isFinite else { return 0 }
        return max(0, min(1, halo))
    }

    /// Effective glow strength: `max(halo, bloom ? bloomLevel : 0)`.
    /// 0 means no shadow at all.
    @inline(__always)
    static func level(
        remappedOpacity r: Double,
        bloom: Bool,
        halo: Double
    ) -> Double {
        let h = clampHalo(halo)
        let b = bloom ? bloomLevel(remappedOpacity: r) : 0
        return max(h, b)
    }
}

extension View {
    /// Apply the dot-matrix bloom/halo to a dot view. `level` is the
    /// effective strength returned by `DotMatrixBloom.level(...)`. `dotSize`
    /// is the dot's diameter — the shadow radius scales off it so small dots
    /// glow tightly and large dots glow soft. `wide` mirrors upstream's
    /// `dmx-bloom-halo` class — when halo is non-zero we use a wider
    /// falloff for a more diffuse look.
    @ViewBuilder
    func dotMatrixBloom(
        level: Double,
        color: Color,
        dotSize: CGFloat,
        wide: Bool
    ) -> some View {
        if level <= 0 {
            self
        } else {
            // Two stacked shadows: a tight inner glow that gives the dot
            // brightness, and a wider outer falloff that gives it softness.
            // Tuned at chat scale (dot ≤ 4pt) — values match the visual
            // weight of upstream's CSS `drop-shadow` stack within rounding.
            let inner = dotSize * (wide ? 0.95 : 0.7)
            let outer = dotSize * (wide ? 1.7 : 1.15)
            self
                .shadow(color: color.opacity(0.55 * level), radius: inner)
                .shadow(color: color.opacity(0.32 * level), radius: outer)
        }
    }
}
