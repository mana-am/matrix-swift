import SwiftUI

/// 16-cell perimeter Möbius chase + back-tail + seam pulse, 1600ms.
public struct DotmSquare20: View {
    var props = DotMatrixCommonProps(pattern: .full)
    init(props: DotMatrixCommonProps) { self.props = props }

    /// Source-parity ergonomic init — mirrors `<DotmSquare20 size=… />` upstream. The
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


    private static let TAIL_BRIGHT: [Double] = [1, 0.82, 0.64, 0.46, 0.3, 0.18]
    private static let BACK_TAIL_BRIGHT: [Double] = [0.38, 0.3, 0.22, 0.14]
    private static let BASE_OPACITY: Double = 0.08
    private static let TWIST_INNER_OPACITY: Double = 0.52
    private static let SEAM_PULSE_OPACITY: Double = 0.55
    private static let IDLE_RING_OPACITY: Double = 0.48

    private static let PERIMETER_PATH: [Int] = [
        rowMajorIndex(0, 0), rowMajorIndex(0, 1), rowMajorIndex(0, 2), rowMajorIndex(0, 3), rowMajorIndex(0, 4),
        rowMajorIndex(1, 4), rowMajorIndex(2, 4), rowMajorIndex(3, 4), rowMajorIndex(4, 4),
        rowMajorIndex(4, 3), rowMajorIndex(4, 2), rowMajorIndex(4, 1), rowMajorIndex(4, 0),
        rowMajorIndex(3, 0), rowMajorIndex(2, 0), rowMajorIndex(1, 0)
    ]

    private static let LOOP_LEN = PERIMETER_PATH.count  // 16

    /// Corner step → one cell inside the strip at the fold (half-twist cue).
    private static let TWIST_INNER: [Int: Int] = [
        0:  rowMajorIndex(1, 1),
        4:  rowMajorIndex(1, 3),
        8:  rowMajorIndex(3, 3),
        12: rowMajorIndex(3, 1)
    ]

    private static func opacityFromTail(_ distance: Int, _ tail: [Double]) -> Double {
        guard distance >= 0 && distance < tail.count else { return 0 }
        return tail[distance]
    }

    public var body: some View {
        let loopLen = Self.LOOP_LEN
        DotMatrixBase(props: props) { ctx, now in
            let onLoop = Self.PERIMETER_PATH.firstIndex(of: ctx.index) ?? -1
            let headStep = steppedCycle(now: now, cycleMsBase: 1600, steps: loopLen, speed: 1, active: ctx.phase != .idle && !ctx.reducedMotion)
            let backHead = (headStep + loopLen / 2) % loopLen

            if ctx.reducedMotion || ctx.phase == .idle {
                if onLoop >= 0 { return Self.IDLE_RING_OPACITY }
                if ctx.index == rowMajorIndex(2, 2) { return 0.22 }
                return Self.BASE_OPACITY
            }

            var opacity = Self.BASE_OPACITY

            if onLoop >= 0 {
                let forward = (headStep - onLoop + loopLen) % loopLen
                let alongBack = (backHead - onLoop + loopLen) % loopLen
                let fwd = Self.opacityFromTail(forward, Self.TAIL_BRIGHT)
                let bck = Self.opacityFromTail(alongBack, Self.BACK_TAIL_BRIGHT)
                opacity = max(opacity, max(fwd, bck))
            }

            if let twistInner = Self.TWIST_INNER[headStep], twistInner == ctx.index {
                opacity = max(opacity, Self.TWIST_INNER_OPACITY)
            }

            let seam = rowMajorIndex(2, 2)
            if ctx.index == seam && headStep % 4 == 0 {
                opacity = max(opacity, Self.SEAM_PULSE_OPACITY)
            }

            return min(1, opacity)
        }
    }
}
