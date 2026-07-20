import SwiftUI

/// Resolves the dot color for a `MatrixLoadingView` from a per-instance seed.
///
/// Picks from a compact, high-chroma palette inspired by luminous LED matrices:
/// green, red, electric blue, cyan, violet, magenta, and amber. The animation
/// already communicates "working", so these hues read as energy rather than
/// status outcomes; the peak-driven bloom supplies the bright core and falloff.
///
/// Theme-aware: dark mode keeps the source near full brightness for a neon
/// appearance, while light mode lowers brightness enough to preserve contrast
/// against white chat surfaces.
///
/// When `useRandom` is false the caller's `fallback` color (typically
/// `Color(.secondaryLabel)`) is returned unchanged so theme-adaptive colors keep
/// working — this is also the path Reduce Motion forces so its static state
/// stays neutral.
enum MatrixLoadingColor {

    /// Curated hue stops in the [0…1) HSB hue space. Each stop remains visually
    /// distinct at chat-icon scale, where low-saturation colors collapse to gray.
    private static let huePalette: [Double] = [
        0.37,   // vivid green
        0.99,   // signal red
        0.58,   // electric blue
        0.53,   // cyan
        0.68,   // indigo
        0.77,   // violet
        0.91,   // magenta
        0.10,   // amber
    ]

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
        let hueIdx = hash % huePalette.count
        let hue = huePalette[hueIdx]
        // Small per-instance jitter avoids identical cards without muting the hue.
        let jitter = Double((hash / huePalette.count) % 4) / 20.0   // 0…0.15

        switch colorScheme {
        case .dark:
            return Color(
                hue: hue,
                saturation: 0.88 - jitter * 0.20,
                brightness: 1.00 - jitter * 0.08
            )
        default:
            return Color(
                hue: hue,
                saturation: 0.78 - jitter * 0.12,
                brightness: 0.78 - jitter * 0.08
            )
        }
    }
}
