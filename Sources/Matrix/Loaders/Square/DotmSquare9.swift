import SwiftUI

/// Two 2×3 Braille cells driven by `dmx-square9-d1..d6` keyframes (steps(52, end), 5200ms).
/// Mixed scale loader: idle / non-braille cells use source 0.08/0.26/0.12 scale (JS path);
/// animated braille cells use CSS-class keyframe scale (0.16/0.32/1.0). Each path is
/// remapped to the user opacity triplet inline so we can `bypassOpacityRemap: true`.
public struct DotmSquare9: View {
    var props = DotMatrixCommonProps(pattern: .full)
    init(props: DotMatrixCommonProps) { self.props = props }

    /// Source-parity ergonomic init — mirrors `<DotmSquare9 size=… />` upstream. The
    /// loader's shape/pattern is fixed; you size and color it.
    public init(
        size: CGFloat = 24,
        color: Color = .primary,
        speed: Double = 1,
        dotSize: CGFloat? = nil,
        muted: Bool = false,
        bloom: Bool = false,
        halo: Double = 0
    ) {
        props.size = size
        props.color = color
        props.speed = speed
        props.dotSize = dotSize ?? max(2, floor(size / 6))
        props.muted = muted
        props.bloom = bloom
        props.halo = halo
    }


    // Braille bit constants (ISO/Unicode braille dot numbering)
    private static let D1: Int = 0x01
    private static let D2: Int = 0x02
    private static let D3: Int = 0x04
    private static let D4: Int = 0x08
    private static let D5: Int = 0x10
    private static let D6: Int = 0x20

    /// Left column "odd" / right column "even" checkerboard.
    private static let CHECK_A: Int = D1 | D3 | D5   // 0x15

    private static let BASE_OPACITY: Double = 0.08
    private static let MID_OPACITY: Double = 0.26
    private static let GAP_OPACITY: Double = 0.12

    private static let CELL_ROW_START = 1
    private static let LEFT_COL = 0
    private static let RIGHT_CELL_COL = 3

    /// Returns braille bit for this (row,col), or nil if not in either cell.
    private static func brailleBit(row: Int, col: Int) -> Int? {
        guard row >= CELL_ROW_START && row <= CELL_ROW_START + 2 else { return nil }
        let dr = row - CELL_ROW_START
        if col == LEFT_COL {
            return D1 << dr
        } else if col == LEFT_COL + 1 {
            return D4 << dr
        } else if col == RIGHT_CELL_COL {
            return D1 << dr
        } else if col == RIGHT_CELL_COL + 1 {
            return D4 << dr
        }
        return nil
    }

    public var body: some View {
        DotMatrixBase(props: props, bypassOpacityRemap: true) { ctx, now in
            let baseOp = props.opacityBase ?? DMKeyframes.DEFAULT_BASE
            let peakOp = props.opacityPeak ?? DMKeyframes.DEFAULT_PEAK
            // Helper: remap a source-scale value into user triplet.
            func remapped(_ v: Double) -> Double {
                remapOpacityToTriplet(
                    v, base: props.opacityBase, mid: props.opacityMid, peak: props.opacityPeak)
            }

            // Gap column (col=2) in braille rows — JS source-scale value
            if ctx.row >= Self.CELL_ROW_START && ctx.row <= Self.CELL_ROW_START + 2 && ctx.col == 2 {
                return remapped(Self.GAP_OPACITY)
            }

            guard let bit = Self.brailleBit(row: ctx.row, col: ctx.col) else {
                return remapped(Self.BASE_OPACITY)
            }

            if ctx.reducedMotion || ctx.phase == .idle {
                let on = (Self.CHECK_A & bit) != 0
                return remapped(on ? Self.MID_OPACITY : Self.BASE_OPACITY)
            }

            let cycleSec = 5.2
            let t = DMKeyframes.phaseWithDelay(now: now, cycleSec: cycleSec, delaySec: 0)
            if bit == Self.D1 { return DMKeyframes.square9D1(t, base: baseOp, peak: peakOp) }
            if bit == Self.D2 { return DMKeyframes.square9D2(t, base: baseOp, peak: peakOp) }
            if bit == Self.D3 { return DMKeyframes.square9D3(t, base: baseOp, peak: peakOp) }
            if bit == Self.D4 { return DMKeyframes.square9D4(t, base: baseOp, peak: peakOp) }
            if bit == Self.D5 { return DMKeyframes.square9D5(t, base: baseOp, peak: peakOp) }
            return DMKeyframes.square9D6(t, base: baseOp, peak: peakOp)
        }
    }
}
