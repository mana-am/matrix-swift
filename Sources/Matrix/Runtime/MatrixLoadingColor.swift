import SwiftUI

/// Resolves the dot color for a `MatrixLoadingView` from a per-instance seed.
///
/// Picks from a **curated muted palette** rather than the full HSB hue space.
/// Two reasons:
///
/// 1. **No green.** A uniform 0–360° hue sample regularly lands in the green/teal
///    band (≈80°–170°), which clashes with Mana's black/gray/white minimalist
///    palette and reads as "system status" (loading-success-green) instead of a
///    neutral accent.
/// 2. **More subtle (素).** The old uniform sample produced occasional vivid
///    pastels. The curated set is hand-picked muted hues — blues, lavenders,
///    dusty pinks, warm peaches — so any seed lands on something that feels
///    like a soft brand accent rather than candy color.
///
/// Theme-aware: in dark mode the same hue is rendered at high brightness +
/// very low saturation (a softly tinted near-white) so dots stay readable on
/// the near-black bubble background. The legacy Pixel didn't need this
/// adjustment because it stacked brightness + shadow layers; the new loaders
/// render a single `Circle()` per cell so the base color must carry contrast
/// on its own.
///
/// When `useRandom` is false the caller's `fallback` color (typically
/// `Color(.secondaryLabel)`) is returned unchanged so theme-adaptive colors keep
/// working — this is the path Reduce Motion forces, since static + faint pastel
/// is essentially invisible.
enum MatrixLoadingColor {

    /// Curated hue stops in the [0…1) HSB hue space. **Greens (≈0.22–0.47)
    /// and teals (≈0.47–0.55) are intentionally excluded.** Each entry is a
    /// muted brand-adjacent accent: cool blues, lavender/violet, dusty pinks
    /// and corals, warm peach. Pick by `seed % count`.
    private static let huePalette: [Double] = [
        0.58,   // slate blue
        0.62,   // dusty blue
        0.68,   // periwinkle
        0.72,   // soft lavender
        0.78,   // muted violet
        0.83,   // dusty mauve
        0.92,   // dusty pink
        0.97,   // soft rose
        0.02,   // warm coral
        0.06,   // soft peach
        0.10,   // sandy peach
        0.13,   // muted amber
    ]

    /// Probability (out of 100) that a random seed lands on the neutral
    /// black/dark-gray fallback instead of the muted hue palette. Tuned so the
    /// chat stream reads as "mostly neutral with occasional color accents"
    /// rather than a candy-colored grid.
    private static let neutralWeight = 55

    static func resolve(
        seed: Int,
        useRandom: Bool,
        fallback: Color,
        colorScheme: ColorScheme
    ) -> Color {
        guard useRandom else { return fallback }
        // Same hash-mix as before so loader pick and color picks decorrelate
        // across consecutive seeds (avoid same-pool-index always pairing with
        // same hue-index).
        let hash = (seed &* 7) & 0x7FFF_FFFF
        // High bits decide neutral-vs-color, low bits decide hue. Using a
        // separate slice keeps the gate uncorrelated with hue index so the
        // remaining colored picks stay evenly distributed across the palette.
        if (hash >> 8) % 100 < neutralWeight {
            return fallback
        }
        let hueIdx = hash % huePalette.count
        let hue = huePalette[hueIdx]
        // Per-instance lightness jitter, so two cards that pick the same hue
        // index aren't pixel-identical.
        let jitter = Double((hash / huePalette.count) % 4) / 8.0   // 0…0.375

        switch colorScheme {
        case .dark:
            // Near-white tinted highlight. Saturation kept very low so the
            // tint reads as "warm gray" / "cool gray" rather than as a
            // colored dot.
            return Color(
                hue: hue,
                saturation: 0.16 - jitter * 0.06,   // 0.13…0.16
                brightness: 0.93 - jitter * 0.04    // 0.91…0.93
            )
        default:
            // Light mode: muted pastel with enough chroma to be visible on
            // white but well under the threshold where it reads as a vivid
            // accent. Roughly the saturation of weathered pastel paint.
            return Color(
                hue: hue,
                saturation: 0.30 - jitter * 0.08,   // 0.22…0.30
                brightness: 0.72 + jitter * 0.04    // 0.72…0.74
            )
        }
    }
}
