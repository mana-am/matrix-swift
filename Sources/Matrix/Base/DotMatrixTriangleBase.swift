import SwiftUI

/// 7×7 triangle-silhouette base. Mirrors the self-contained render body shared by
/// every `dotm-triangle-*.tsx` loader: a 7×7 grid where only the 10 triangle
/// cells are lit, each driven by a per-loader opacity resolver.
///
/// Unlike `DotMatrixBase` (5×5), triangle loaders never draw ghost inactive dots
/// — off-silhouette cells are fully hidden (`dmx-inactive`). The resolver returns
/// a raw source-scale opacity; the base applies `remapOpacityToTriplet`, muted
/// dimming and bloom/halo, exactly like the hex base.
///
/// `scaledNow` is pre-multiplied by `speed`; resolvers pass `speed: 1` to the
/// `steppedCycle` / `cyclePhase` clock helpers. `active` is
/// `phase != .idle && !reducedMotion` — resolvers use it to pick their idle
/// pose (some hold a fixed phase rather than freezing at 0).
struct DotMatrixTriangleBase: View {
    typealias Resolver = (_ row: Int, _ col: Int, _ now: TimeInterval, _ active: Bool) -> Double

    let props: DotMatrixCommonProps
    let resolver: Resolver

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// The 10 lit cells of the 1-2-3-4 staggered triangle, as row-major indices
    /// on a 7×7 grid. Shared by all `DotmTriangle*` loaders.
    static let mask: Set<Int> = {
        let cells: [(Int, Int)] = [
            (1, 3), (2, 2), (2, 4), (3, 1), (3, 3), (3, 5), (4, 0), (4, 2), (4, 4), (4, 6),
        ]
        return Set(cells.map { $0.0 * SIZE + $0.1 })
    }()

    static let SIZE = 7

    @inline(__always)
    static func isActive(_ row: Int, _ col: Int) -> Bool {
        guard row >= 0, row < SIZE, col >= 0, col < SIZE else { return false }
        return mask.contains(row * SIZE + col)
    }

    var body: some View {
        let safeSpeed = props.speed > 0 ? props.speed : 1
        let n = CGFloat(Self.SIZE)
        let gap: CGFloat = props.cellPadding ?? max(1, floor((props.size - props.dotSize * n) / (n - 1)))
        let matrixSize = props.dotSize * n + gap * (n - 1)
        let phase = resolveMatrixPhase(animated: props.animated, reducedMotion: reduceMotion)
        let active = phase != .idle

        let matrix = TimelineView(.animation(paused: phase == .idle)) { context in
            let now = context.date.timeIntervalSinceReferenceDate * safeSpeed
            VStack(spacing: gap) {
                ForEach(0..<Self.SIZE, id: \.self) { row in
                    HStack(spacing: gap) {
                        ForEach(0..<Self.SIZE, id: \.self) { col in
                            cell(row: row, col: col, now: now, active: active)
                        }
                    }
                }
            }
            .frame(width: matrixSize, height: matrixSize)
        }

        matrix
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(
                Text(
                    "loader.matrix.accessibilityLabel",
                    bundle: .module,
                    comment: "VoiceOver label for the chat loading dot-matrix indicator"
                )
            )
    }

    @ViewBuilder
    private func cell(row: Int, col: Int, now: TimeInterval, active: Bool) -> some View {
        let isOn = Self.isActive(row, col)
        let raw = isOn ? resolver(row, col, now, active) : 0
        let remapped = isOn
            ? remapOpacityToTriplet(
                raw, base: props.opacityBase, mid: props.opacityMid, peak: props.opacityPeak)
            : 0
        let display = isOn ? (props.muted ? remapped * 0.44 : remapped) : 0
        let level = isOn
            ? DotMatrixBloom.level(remappedOpacity: remapped, bloom: props.bloom, halo: props.halo)
            : 0
        Circle()
            .fill(props.color)
            .frame(width: props.dotSize, height: props.dotSize)
            .opacity(display)
            .dotMatrixBloom(
                level: level,
                color: props.color,
                dotSize: props.dotSize,
                wide: DotMatrixBloom.clampHalo(props.halo) > 0
            )
    }
}
