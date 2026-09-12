import SwiftUI

/// 5×5 dot-matrix base view. Mirrors `loaders/base/dot-matrix-base.tsx`. Each loader supplies
/// a resolver closure `(DotAnimationContext, scaledNow) -> opacity` that is evaluated for
/// each of the 25 cells per animation frame.
///
/// `scaledNow` already factors in `props.speed` (CSS multiplied animation duration by
/// `--dmx-speed = 1 / speed`; we pre-multiply now by `speed` so the resolver can ignore it).
struct DotMatrixBase: View {
    typealias Resolver = (DotAnimationContext, TimeInterval) -> Double

    let props: DotMatrixCommonProps
    /// CSS-class style loaders return values already in the user's opacity-triplet scale
    /// (because they pass user overrides into the keyframe). They should bypass the
    /// source-scale remap to avoid a double-remap.
    var bypassOpacityRemap: Bool = false
    let resolver: Resolver

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Frame-rate ceiling for the animation clock.
    ///
    /// A bare `.animation` schedule follows the display link, so on a ProMotion
    /// device this body ran 120×/s — and one pass is not cheap: it rebuilds all
    /// 25 cells, and every cell above the bloom threshold carries three
    /// `.shadow` layers plus a `.brightness` filter, each of which CoreAnimation
    /// rasterizes into the layer's backing store on the CPU. An Instruments
    /// trace of a host app put ~8% of ALL main-thread time in
    /// `CABackingStoreUpdate_`, with its per-second distribution matching this
    /// view's lifetime exactly.
    ///
    /// The loaders animate slow opacity pulses, so capping the clock at 30fps
    /// is not visible — but on a 120Hz display it removes three quarters of
    /// that redraw cost. Devices at 60Hz are unaffected below their own rate.
    private static let frameInterval: TimeInterval = 1.0 / 30.0

    var body: some View {
        let safeSpeed = props.speed > 0 ? props.speed : 1
        let layout = matrix5Layout(
            size: props.size, dotSize: props.dotSize, cellPadding: props.cellPadding)
        let outer = resolveBoxOuterDim(boxSize: props.boxSize, minSize: props.minSize)
        let scale =
            outer.useWrapper && layout.matrixSpan > 0 ? outer.outerDim / layout.matrixSpan : 1
        let phase = resolveMatrixPhase(animated: props.animated, reducedMotion: reduceMotion)
        let mask = DotMatrixPatterns.mask(for: props.pattern)

        let matrix = TimelineView(
            .animation(minimumInterval: Self.frameInterval, paused: phase == .idle)
        ) { context in
            let now = context.date.timeIntervalSinceReferenceDate * safeSpeed
            VStack(spacing: layout.gap) {
                ForEach(0..<MATRIX_SIZE, id: \.self) { row in
                    HStack(spacing: layout.gap) {
                        ForEach(0..<MATRIX_SIZE, id: \.self) { col in
                            cell(row: row, col: col, mask: mask, phase: phase, now: now)
                        }
                    }
                }
            }
            .frame(width: layout.matrixSpan, height: layout.matrixSpan)
        }

        Group {
            if outer.useWrapper {
                matrix.scaleEffect(scale)
                    .frame(width: outer.outerDim, height: outer.outerDim)
            } else {
                matrix
            }
        }
        .accessibilityElement(children: .ignore)
        // Localized via Localizable.xcstrings — Xcode's string-extraction tool
        // resolves from this package's own catalog (`bundle: .module`,
        // `Resources/Localizable.xcstrings`, en + zh-Hans). Other locales fall
        // back to English.
        .accessibilityLabel(
            Text(
                "loader.matrix.accessibilityLabel",
                bundle: .module,
                comment: "VoiceOver label for the chat loading dot-matrix indicator"
            )
        )
    }

    @ViewBuilder
    private func cell(row: Int, col: Int, mask: [Bool], phase: MatrixPhase, now: TimeInterval)
        -> some View
    {
        let index = rowMajorIndex(row, col)
        let active = mask[index]
        let opacity = active ? computeOpacity(index: index, row: row, col: col, phase: phase, now: now) : 0
        let displayOpacity: Double = {
            if active {
                return props.muted ? opacity * 0.44 : opacity
            }
            // Inactive cell: either drawn faintly as a "ghost" or fully hidden.
            return props.showInactiveDots ? props.inactiveDotOpacity : 0
        }()
        // Bloom drives off the cell's REMAPPED opacity (the same value the
        // dot is rendered at), not the raw resolver output — `opacity-min`
        // (0.6) is on the remapped scale.
        let bloomLevel = active ? DotMatrixBloom.level(
            remappedOpacity: opacity,
            bloom: props.bloom,
            halo: props.halo
        ) : 0
        Circle()
            .fill(props.color)
            .frame(width: props.dotSize, height: props.dotSize)
            .opacity(displayOpacity)
            .dotMatrixBloom(
                level: bloomLevel,
                color: props.color,
                dotSize: props.dotSize,
                wide: DotMatrixBloom.clampHalo(props.halo) > 0
            )
    }

    private func computeOpacity(
        index: Int, row: Int, col: Int, phase: MatrixPhase, now: TimeInterval
    ) -> Double {
        let ctx = DotAnimationContext(
            index: index, row: row, col: col,
            distanceFromCenter: distanceFromCenter5x5(index),
            polarAngle: DotMatrixMath.polarAngle(index),
            radiusNormalized: DotMatrixMath.normalizedRadius(index),
            manhattanDistance: DotMatrixMath.manhattanDistance(index),
            phase: phase, isActive: true, reducedMotion: reduceMotion
        )
        let raw = resolver(ctx, now)
        if bypassOpacityRemap {
            return max(0, min(1, raw))
        }
        return remapOpacityToTriplet(
            raw, base: props.opacityBase, mid: props.opacityMid, peak: props.opacityPeak)
    }
}

// MARK: - layout helpers

struct Matrix5Layout {
    let gap: CGFloat
    let matrixSpan: CGFloat
}

func matrix5Layout(size: CGFloat, dotSize: CGFloat, cellPadding: CGFloat?) -> Matrix5Layout {
    let n = CGFloat(MATRIX_SIZE)
    if let p = cellPadding {
        let gap = max(0, p)
        return Matrix5Layout(gap: gap, matrixSpan: dotSize * n + gap * (n - 1))
    }
    let gap = max(1, floor((size - dotSize * n) / (n - 1)))
    return Matrix5Layout(gap: gap, matrixSpan: size)
}

struct BoxOuterDim {
    let outerDim: CGFloat
    let useWrapper: Bool
}

func resolveBoxOuterDim(boxSize: CGFloat?, minSize: CGFloat?) -> BoxOuterDim {
    guard let b = boxSize, b > 0, b.isFinite else {
        return BoxOuterDim(outerDim: 0, useWrapper: false)
    }
    if let m = minSize, m > 0, m.isFinite {
        return BoxOuterDim(outerDim: max(b, m), useWrapper: true)
    }
    return BoxOuterDim(outerDim: b, useWrapper: true)
}
