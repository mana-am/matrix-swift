import SwiftUI

/// Per-cell animation context for 3×3 loaders. Mirrors the object passed to
/// `animationResolver` in `dot-matrix-3-base.tsx`.
struct DotAnimationContext3 {
    let index: Int
    let row: Int
    let col: Int
    let distanceFromCenter: Double
    let angleFromCenter: Double
    let radiusNormalized: Double
    let manhattanDistance: Int
    let phase: MatrixPhase
    let isActive: Bool
    let reducedMotion: Bool
}

/// 3×3 dot-matrix base view. Mirrors `loaders/base/dot-matrix-3-base.tsx`. The
/// structure is identical to `DotMatrixBase` (5×5) — only the grid size and the
/// default `opacityBase` (0.06 upstream) differ. Each loader supplies a resolver
/// `(DotAnimationContext3, scaledNow) -> opacity`.
///
/// `scaledNow` already factors in `props.speed` (the CSS `--dmx-speed = 1/speed`
/// scales duration; we pre-multiply `now` by `speed` so resolvers ignore it).
struct DotMatrix3Base: View {
    typealias Resolver = (DotAnimationContext3, TimeInterval) -> Double

    let props: DotMatrixCommonProps
    /// CSS-class style loaders feed the user triplet into their keyframe and
    /// return values already on that scale — they must skip the source remap.
    var bypassOpacityRemap: Bool = false
    let resolver: Resolver

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        let safeSpeed = props.speed > 0 ? props.speed : 1
        let layout = matrix3Layout(
            size: props.size, dotSize: props.dotSize, cellPadding: props.cellPadding)
        let outer = resolveBoxOuterDim(boxSize: props.boxSize, minSize: props.minSize)
        let scale =
            outer.useWrapper && layout.matrixSpan > 0 ? outer.outerDim / layout.matrixSpan : 1
        let phase = resolveMatrixPhase(animated: props.animated, reducedMotion: reduceMotion)
        let mask = DotMatrix3.mask(for: props.pattern)

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
        let block = pitch * CGFloat(DotMatrix3.SIZE) - layout.gap
        let inset = (layout.matrixSpan - block) / 2 + props.dotSize / 2
        var cells: [DotFieldCell] = []
        cells.reserveCapacity(DotMatrix3.SIZE * DotMatrix3.SIZE)
        for row in 0..<DotMatrix3.SIZE {
            for col in 0..<DotMatrix3.SIZE {
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
        let index = DotMatrix3.rowMajorIndex(row, col)
        let active = mask[index]
        let opacity = active ? computeOpacity(index: index, row: row, col: col, phase: phase, now: now) : 0
        let displayOpacity: Double = {
            if active {
                return props.muted ? opacity * 0.44 : opacity
            }
            return props.showInactiveDots ? props.inactiveDotOpacity : 0
        }()
        let bloomLevel = active ? DotMatrixBloom.level(
            remappedOpacity: opacity, bloom: props.bloom, halo: props.halo
        ) : 0
        return DotFieldCell(center: center, opacity: displayOpacity, bloom: bloomLevel)
    }

    private func computeOpacity(
        index: Int, row: Int, col: Int, phase: MatrixPhase, now: TimeInterval
    ) -> Double {
        let ctx = DotAnimationContext3(
            index: index, row: row, col: col,
            distanceFromCenter: DotMatrix3.distanceFromCenter(index),
            angleFromCenter: DotMatrix3.polarAngle(index),
            radiusNormalized: DotMatrix3.radiusNormalized(index),
            manhattanDistance: DotMatrix3.manhattanDistance(index),
            phase: phase, isActive: true, reducedMotion: reduceMotion
        )
        let raw = resolver(ctx, now)
        if bypassOpacityRemap {
            return max(0, min(1, raw))
        }
        // Upstream 3×3 default opacityBase is 0.06 when the caller doesn't override.
        return remapOpacityToTriplet(
            raw,
            base: props.opacityBase ?? 0.06,
            mid: props.opacityMid,
            peak: props.opacityPeak
        )
    }
}

// MARK: - layout

/// `getMatrix3Layout` — mirrors `core/matrix-layout-3.ts`. Note upstream uses
/// `Math.max(0, …)` for the auto gap (unlike the 5×5 layout's `max(1, …)`).
func matrix3Layout(size: CGFloat, dotSize: CGFloat, cellPadding: CGFloat?) -> Matrix5Layout {
    let n = CGFloat(DotMatrix3.SIZE)
    if let p = cellPadding {
        let gap = max(0, p)
        return Matrix5Layout(gap: gap, matrixSpan: dotSize * n + gap * (n - 1))
    }
    let gap = max(0, floor((size - dotSize * n) / (n - 1)))
    return Matrix5Layout(gap: gap, matrixSpan: size)
}
