import SwiftUI

/// 5×5 diamond pattern icon. Mirrors `loaders/dot-matrix-icon.tsx`.
///
/// CSS contract per `styles.css`:
///   .dmx-ripple — cycle = `--dmx-cycle (1500ms)` × `--dmx-speed`,
///   delay = `Round(distanceFromCenter) * 0.2333 * cycle`,
///   cubic-bezier(0.42, 0, 0.58, 1).
public struct DotMatrixIcon: View {
    var props: DotMatrixCommonProps

    public init(
        size: CGFloat = 24,
        dotSize: CGFloat = 3,
        color: Color = .primary,
        speed: Double = 1,
        animated: Bool = true,
        muted: Bool = false,
        cellPadding: CGFloat? = nil,
        showInactiveDots: Bool = false,
        inactiveDotOpacity: Double = 0.06,
        halo: Double = 0,
        bloom: Bool = false,
        opacityBase: Double? = nil,
        opacityMid: Double? = nil,
        opacityPeak: Double? = nil
    ) {
        self.props = DotMatrixCommonProps(
            size: size,
            dotSize: dotSize,
            color: color,
            speed: speed,
            pattern: .diamond,
            muted: muted,
            animated: animated,
            opacityBase: opacityBase,
            opacityMid: opacityMid,
            opacityPeak: opacityPeak,
            cellPadding: cellPadding,
            showInactiveDots: showInactiveDots,
            inactiveDotOpacity: inactiveDotOpacity,
            bloom: bloom,
            halo: halo
        )
    }

    public var body: some View {
        DotMatrixBase(props: props, bypassOpacityRemap: true) { ctx, now in
            let baseOp = props.opacityBase ?? DMKeyframes.DEFAULT_BASE
            let peakOp = props.opacityPeak ?? DMKeyframes.DEFAULT_PEAK
            let cycleSec = 1.5  // --dmx-cycle 1500ms
            let ring = ctx.distanceFromCenter.rounded()
            let delaySec = ring * 0.2333 * cycleSec
            switch ctx.phase {
            case .idle:
                // .dmx-dot fallback opacity = 0.5 * (base + mid)
                let midOp = props.opacityMid ?? DMKeyframes.DEFAULT_MID
                return 0.5 * (baseOp + midOp)
            case .loadingRipple:
                let t = DMKeyframes.phaseWithDelay(
                    now: now, cycleSec: cycleSec, delaySec: delaySec
                )
                return DMKeyframes.ripple(t, base: baseOp, peak: peakOp)
            case .collapse, .hoverRipple:
                // hover phases unused on iOS; resolve to base.
                return baseOp
            }
        }
    }
}
