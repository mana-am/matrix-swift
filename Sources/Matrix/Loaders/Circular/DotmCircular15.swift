import SwiftUI

/// 6-frame Braille phase cycle on circle mask.
public struct DotmCircular15: View {
    var props = DotMatrixCommonProps(pattern: .full)
    init(props: DotMatrixCommonProps) { self.props = props }

    /// Source-parity ergonomic init — mirrors `<DotmCircular15 size=… />` upstream. The
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

    private static let BASE_OPACITY: Double = 0.07
    private static let MID_OPACITY: Double = 0.34
    private static let HIGH_OPACITY: Double = 0.95

    // Verbatim from .tsx BRAILLE_PHASES
    private static let BRAILLE_PHASES: [Set<String>] = [
        ["1,1", "2,1", "3,1", "1,3", "2,3", "3,3"],         // rails
        ["1,1", "2,1", "3,1", "2,2", "1,3", "2,3", "3,3"],  // center bridge
        ["1,1", "1,2", "1,3", "2,1", "2,3", "3,1", "3,2", "3,3"], // top+bottom bars
        ["1,1", "3,1", "2,2", "1,3", "3,3"],                 // X-cross
        ["2,1", "1,2", "3,2", "2,3"],                        // plus motif
        ["1,1", "2,1", "2,2", "2,3", "3,3"],                 // diagonal sweep
    ]

    public var body: some View {
        DotMatrixBase(props: props) { ctx, now in
            guard isWithinCircularMask(row: ctx.row, col: ctx.col) else { return 0 }

            let x = Double(ctx.col - 2)
            let y = Double(ctx.row - 2)
            let ring = (x * x + y * y).squareRoot()
            let count = Self.BRAILLE_PHASES.count
            let animPhase = cyclePhase(now: now, cycleMsBase: 1680, speed: 1,
                                       active: !ctx.reducedMotion && ctx.phase != .idle)
            let rawIndex = ctx.reducedMotion || ctx.phase == .idle
                ? 0
                : Int(floor(animPhase * Double(count)))
            let phaseIndex = ((rawIndex % count) + count) % count
            let previousIndex = (phaseIndex + count - 1) % count

            let key = "\(ctx.row),\(ctx.col)"
            let inPattern = Self.BRAILLE_PHASES[phaseIndex].contains(key)
            let inPrevPattern = Self.BRAILLE_PHASES[previousIndex].contains(key)

            var opacity = Self.BASE_OPACITY
            if inPattern {
                opacity = Self.HIGH_OPACITY
            } else if inPrevPattern {
                opacity = Self.MID_OPACITY
            } else if ring < 1.1 {
                opacity = 0.2
            }

            return opacity
        }
    }
}
