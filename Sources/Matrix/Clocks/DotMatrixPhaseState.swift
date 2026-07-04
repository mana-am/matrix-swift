import SwiftUI

/// Mirrors React `useDotMatrixPhases`: on iOS we don't drive hover, so phase is just
/// `loadingRipple` (when animated) or `idle` (reduced motion / disabled).
@inline(__always)
func resolveMatrixPhase(animated: Bool, reducedMotion: Bool) -> MatrixPhase {
    (animated && !reducedMotion) ? .loadingRipple : .idle
}

/// SwiftUI doesn't expose `prefers-reduced-motion` directly; iOS uses `accessibilityReduceMotion`.
struct ReducedMotionEnvironment {
    @Environment(\.accessibilityReduceMotion) var reduce
}
