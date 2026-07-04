import SwiftUI

/// Triangle 2 — altitude-weighted vertical pulse; each row lights slightly out
/// of phase so the wave climbs the triangle. Stepped cycle (36 steps, 1550ms).
/// Mirrors `dotm-triangle-2.tsx`.
struct DotmTriangle2: View {
    var props = DotMatrixCommonProps(size: 30, dotSize: 4, pattern: .full)

    private static let STEP_COUNT = 36
    private static let BASE_OPACITY = 0.08
    private static let MID_OPACITY = 0.34
    private static let HIGH_OPACITY = 0.94

    var body: some View {
        DotMatrixTriangleBase(props: props) { row, col, now, active in
            let frame = steppedCycle(
                now: now, cycleMsBase: 1550, steps: Self.STEP_COUNT, speed: 1, active: active)
            let progress = Double(frame) / Double(Self.STEP_COUNT)
            let rowPhase = Double(4 - row) * 0.13
            let pulse = 0.5 - 0.5 * cos((progress + rowPhase) * Double.pi * 2)
            let crest = pulse * pulse
            let altitudeWeight = 0.58 + Double(4 - row) * 0.16
            let centerWeight = col == 3 ? 0.16 : 0
            var opacity =
                Self.BASE_OPACITY
                + pulse * (Self.MID_OPACITY - Self.BASE_OPACITY)
                + crest * (altitudeWeight + centerWeight) * (Self.HIGH_OPACITY - Self.MID_OPACITY)
            opacity = min(Self.HIGH_OPACITY, opacity)
            return opacity
        }
    }
}
