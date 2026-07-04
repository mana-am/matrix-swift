import SwiftUI

/// Common props mirrored from `DotMatrixCommonProps` in `loaders/types.ts`. Every loader
/// passes these through to `DotMatrixBase` (5×5).
struct DotMatrixCommonProps {
    var size: CGFloat = 24
    var dotSize: CGFloat = 3
    var color: Color = .primary
    var speed: Double = 1
    var pattern: MatrixPattern = .diamond
    var muted: Bool = false
    var animated: Bool = true
    var opacityBase: Double? = nil
    var opacityMid: Double? = nil
    var opacityPeak: Double? = nil
    var cellPadding: CGFloat? = nil
    var boxSize: CGFloat? = nil
    var minSize: CGFloat? = nil

    /// When true, the 5×5 grid renders ALL cells — pattern-active ones drive the loader
    /// animation, pattern-inactive ones are drawn at a faint ghost opacity so the full
    /// dot grid is always visible. Off by default to preserve the upstream library's look.
    var showInactiveDots: Bool = false
    /// Opacity multiplier (× peak) used for inactive ghost dots. 0…1.
    var inactiveDotOpacity: Double = 0.06
    /// Optional fill behind the matrix. `nil` = transparent.
    var backgroundColor: Color? = nil
    /// Corner radius of the optional background fill. Ignored if `backgroundColor` is nil.
    var backgroundCornerRadius: CGFloat = 6

    /// When `true`, dots above the bloom threshold (≥0.6 remapped opacity) emit
    /// a glow proportional to how far above the threshold they sit. Mirrors
    /// upstream's `bloom` prop / `dmxDotBloomParts` math; effectively a
    /// per-cell `drop-shadow` rendered as a SwiftUI `.shadow(...)`.
    var bloom: Bool = false
    /// Uniform per-dot glow strength in `0…1`, applied regardless of opacity.
    /// Combined with `bloom` via `max(halo, bloomLevel)`. Setting halo > 0 also
    /// widens the glow falloff (the SwiftUI parallel of upstream's
    /// `dmx-bloom-halo` CSS class). Use small values (≤0.2) at chat scale —
    /// large values bleed into surrounding text.
    var halo: Double = 0
}
