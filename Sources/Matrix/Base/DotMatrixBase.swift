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

    var body: some View {
        let safeSpeed = props.speed > 0 ? props.speed : 1
        let layout = matrix5Layout(
            size: props.size, dotSize: props.dotSize, cellPadding: props.cellPadding)
        let outer = resolveBoxOuterDim(boxSize: props.boxSize, minSize: props.minSize)
        let scale =
            outer.useWrapper && layout.matrixSpan > 0 ? outer.outerDim / layout.matrixSpan : 1
        let phase = resolveMatrixPhase(animated: props.animated, reducedMotion: reduceMotion)
        let mask = DotMatrixPatterns.mask(for: props.pattern)

        let matrix = DotField(
            canvasSize: CGSize(width: layout.matrixSpan, height: layout.matrixSpan),
            dotSize: props.dotSize,
            color: props.color,
            wideBloom: DotMatrixBloom.clampHalo(props.halo) > 0,
            paused: phase == .idle
        ) { wallClock in
            let now = wallClock * safeSpeed
            return cells(layout: layout, mask: mask, phase: phase, now: now)
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

    /// One tick of the grid, laid out exactly as the old `VStack`/`HStack`
    /// placed it: `layout.gap` between dots, the block centered in the span.
    private func cells(
        layout: Matrix5Layout, mask: [Bool], phase: MatrixPhase, now: TimeInterval
    ) -> [DotFieldCell] {
        let pitch = props.dotSize + layout.gap
        let block = pitch * CGFloat(MATRIX_SIZE) - layout.gap
        let inset = (layout.matrixSpan - block) / 2 + props.dotSize / 2
        var cells: [DotFieldCell] = []
        cells.reserveCapacity(MATRIX_CELLS)
        for row in 0..<MATRIX_SIZE {
            for col in 0..<MATRIX_SIZE {
                let center = CGPoint(
                    x: inset + CGFloat(col) * pitch, y: inset + CGFloat(row) * pitch)
                cells.append(cell(row: row, col: col, center: center, mask: mask, phase: phase, now: now))
            }
        }
        return cells
    }

    private func cell(
        row: Int, col: Int, center: CGPoint, mask: [Bool], phase: MatrixPhase, now: TimeInterval
    ) -> DotFieldCell {
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
        return DotFieldCell(center: center, opacity: displayOpacity, bloom: bloomLevel)
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
