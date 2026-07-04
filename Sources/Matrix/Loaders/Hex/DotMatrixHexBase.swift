import SwiftUI

/// Hex grid: 5 rows of `[3, 4, 5, 4, 3] = 19` cells, with row pitch
/// `√3/2` so cells form a regular hexagon. Mirrors upstream `dotm-hex-*`
/// loaders (commit 61b8cb07). Resolver receives `(row, col, phase)` and
/// returns a raw opacity in the `0…1` source-triplet scale; the base
/// remaps it to the user's triplet and applies bloom/halo, just like
/// `DotMatrixBase` does for the 5×5 square grid.
///
/// Two timing modes:
///   - `.cycle(cycleMsBase:)` — continuous `[0,1)` phase via wall-clock,
///     used by Hex1–6, 9, 10. Most loaders are math functions of phase.
///   - `.stepped(steps:cycleMsBase:)` — integer step in `0..<steps`,
///     used by Hex7/Hex8 frame-table loaders.
struct DotMatrixHexBase: View {
    typealias Resolver = (_ row: Int, _ col: Int, _ phase: Double) -> Double

    enum Timing {
        case cycle(cycleMsBase: Double)
        case stepped(steps: Int, cycleMsBase: Double)
    }

    let props: DotMatrixCommonProps
    let timing: Timing
    let resolver: Resolver

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        let safeSpeed = props.speed > 0 ? props.speed : 1
        let layout = HexLayout.compute(props: props)
        let phaseState = resolveMatrixPhase(animated: props.animated, reducedMotion: reduceMotion)
        let isPaused = phaseState == .idle

        let matrix = TimelineView(.animation(paused: isPaused)) { context in
            let now = context.date.timeIntervalSinceReferenceDate * safeSpeed
            let phaseValue: Double = {
                guard !isPaused else { return idlePhase() }
                switch timing {
                case .cycle(let ms):
                    return cyclePhase(now: now, cycleMsBase: ms, speed: 1, active: true)
                case .stepped(let steps, let ms):
                    let p = cyclePhase(now: now, cycleMsBase: ms * Double(steps), speed: 1, active: true)
                    return Double(Int(floor(p * Double(steps))) % max(1, steps))
                }
            }()

            VStack(spacing: layout.rowGap) {
                ForEach(0..<HEX_ROWS, id: \.self) { row in
                    HStack(spacing: layout.colGap) {
                        ForEach(0..<HEX_ROW_COUNTS[row], id: \.self) { col in
                            cell(row: row, col: col, phaseValue: phaseValue)
                        }
                    }
                }
            }
            .frame(width: layout.matrixWidth, height: layout.matrixHeight)
        }

        Group {
            if let outerDim = layout.outerDim {
                let scale = layout.matrixSpan > 0 ? outerDim / layout.matrixSpan : 1
                matrix.scaleEffect(scale)
                    .frame(width: outerDim, height: outerDim)
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

    @ViewBuilder
    private func cell(row: Int, col: Int, phaseValue: Double) -> some View {
        let raw = resolver(row, col, phaseValue)
        let remapped = remapOpacityToTriplet(
            raw, base: props.opacityBase, mid: props.opacityMid, peak: props.opacityPeak
        )
        let display = props.muted ? remapped * 0.44 : remapped
        let level = DotMatrixBloom.level(
            remappedOpacity: remapped, bloom: props.bloom, halo: props.halo
        )
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

    private func idlePhase() -> Double {
        switch timing {
        case .cycle:        return 0.1
        case .stepped:      return 0
        }
    }
}

// MARK: - Layout & geometry

let HEX_ROW_COUNTS: [Int] = [3, 4, 5, 4, 3]
let HEX_ROWS = HEX_ROW_COUNTS.count
let HEX_MAX_ROW: Int = HEX_ROW_COUNTS.max() ?? 5
let HEX_ROW_PITCH_RATIO: Double = 0.8660254037844386   // √3/2

struct HexLayout {
    let colGap: CGFloat
    let rowGap: CGFloat
    let matrixWidth: CGFloat
    let matrixHeight: CGFloat
    let matrixSpan: CGFloat
    let outerDim: CGFloat?

    static func compute(props: DotMatrixCommonProps) -> HexLayout {
        let n = CGFloat(HEX_MAX_ROW)
        let dotSize = props.dotSize
        // Column gap matches DotMatrixBase's auto-gap formula when cellPadding
        // isn't given, so hex loaders share the visual cadence of square ones.
        let colGap: CGFloat = {
            if let p = props.cellPadding { return max(0, p) }
            return max(1, floor((props.size - dotSize * n) / (n - 1)))
        }()
        // Row pitch: column pitch × √3/2 minus the dot itself, since SwiftUI's
        // VStack spacing is gap-between-frames not center-to-center.
        let colPitch = dotSize + colGap
        let rowGap = max(1, colPitch * CGFloat(HEX_ROW_PITCH_RATIO) - dotSize)

        let matrixWidth = dotSize * n + colGap * (n - 1)
        let matrixHeight = dotSize * CGFloat(HEX_ROWS) + rowGap * CGFloat(HEX_ROWS - 1)
        let matrixSpan = max(matrixWidth, matrixHeight)

        let outerDim: CGFloat? = {
            if let b = props.boxSize, b > 0, b.isFinite {
                if let m = props.minSize, m > 0, m.isFinite { return max(b, m) }
                return b
            }
            return nil
        }()

        return HexLayout(
            colGap: colGap, rowGap: rowGap,
            matrixWidth: matrixWidth, matrixHeight: matrixHeight,
            matrixSpan: matrixSpan, outerDim: outerDim
        )
    }
}

// MARK: - Cell math helpers (shared by hex loaders)

enum HexCell {
    /// Centered `(x, y)` for a cell in the hex grid. `x` is column offset in
    /// "dot units" (centered on the row), `y` is row offset from center
    /// scaled by the hex pitch so the points sit on a regular hex lattice.
    @inline(__always)
    static func point(row: Int, col: Int) -> (x: Double, y: Double) {
        let count = HEX_ROW_COUNTS[row]
        let x = Double(col) - Double(count - 1) / 2
        let y = Double(row - 2) * HEX_ROW_PITCH_RATIO
        return (x, y)
    }

    /// `(angle, radius)` polar coordinates for a cell. `angle` is `atan2(y, x)`,
    /// `radius` is Euclidean.
    @inline(__always)
    static func polar(row: Int, col: Int) -> (angle: Double, radius: Double) {
        let p = point(row: row, col: col)
        return (atan2(p.y, p.x), sqrt(p.x * p.x + p.y * p.y))
    }

    /// Stable `"r,c"` id used by upstream loaders' VERTEX_PATH / FRAME tables.
    @inline(__always)
    static func id(row: Int, col: Int) -> String { "\(row),\(col)" }
}

// MARK: - Math helpers

@inline(__always)
func dmHexClamp01(_ v: Double) -> Double { max(0, min(1, v)) }

@inline(__always)
func dmHexModF(_ n: Double, _ m: Double) -> Double {
    let r = n.truncatingRemainder(dividingBy: m)
    return r < 0 ? r + m : r
}

@inline(__always)
func dmHexAngularDistance(_ a: Double, _ b: Double) -> Double {
    let d = abs(atan2(sin(a - b), cos(a - b)))
    return min(d, 2 * .pi - d)
}

@inline(__always)
func dmHexAngularDistanceUnsigned(_ a: Double, _ b: Double) -> Double {
    abs(atan2(sin(a - b), cos(a - b)))
}

@inline(__always)
func dmHexSmoothstep01(_ edge0: Double, _ edge1: Double, _ x: Double) -> Double {
    if edge1 <= edge0 { return x >= edge1 ? 1 : 0 }
    let t = max(0, min(1, (x - edge0) / (edge1 - edge0)))
    return t * t * (3 - 2 * t)
}

@inline(__always)
func dmHexTriangularWave(_ n: Double) -> Double {
    let w = dmHexModF(n, 1)
    return 1 - abs(w * 2 - 1)
}

@inline(__always)
func dmHexWrappedDistance(_ a: Double, _ b: Double, mod m: Double) -> Double {
    let diff = abs(a - b).truncatingRemainder(dividingBy: m)
    return min(diff, m - diff)
}

@inline(__always)
func dmHexRipple(_ value: Double, width: Double) -> Double {
    let wrapped = dmHexModF(value, 1)
    let distance = min(wrapped, 1 - wrapped)
    return max(0, 1 - distance / width)
}
