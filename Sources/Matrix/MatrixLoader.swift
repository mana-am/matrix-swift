import SwiftUI

/// A named "fun" loader silhouette.
public enum FunLoader: String, CaseIterable, Sendable {
    case heart, manaM, arrow, sparkle, eye, lightning, flower, wave, hexagon
    case inkBleed, tokenFall, breathing, waveBend, snake, confetti, shimmer, pulseRing, cursor

    /// Internal id in `MatrixLoadingPool`.
    var poolID: String {
        switch self {
        case .heart: return "Heart"
        case .manaM: return "ManaM"
        case .arrow: return "Arrow"
        case .sparkle: return "Sparkle"
        case .eye: return "Eye"
        case .lightning: return "Lightning"
        case .flower: return "Flower"
        case .wave: return "Wave"
        case .hexagon: return "Hexagon"
        case .inkBleed: return "Ink"
        case .tokenFall: return "Tokens"
        case .breathing: return "Breathing"
        case .waveBend: return "WaveBend"
        case .snake: return "Snake"
        case .confetti: return "Confetti"
        case .shimmer: return "Shimmer"
        case .pulseRing: return "Pulse"
        case .cursor: return "Cursor"
        }
    }
}

/// Identifies a specific loader by shape + index. Valid index ranges:
/// `square` 1…23 · `circular` 1…20 · `hex` 1…10 · `grid3` 1…16 & 18…21 ·
/// `triangle` 1…20. Out-of-range indices render nothing.
public enum MatrixLoaderID: Hashable, Sendable {
    case square(Int)
    case circular(Int)
    case hex(Int)
    case grid3(Int)
    case triangle(Int)
    case fun(FunLoader)
    case icon

    /// Every valid loader id in family order — handy for building pickers/random.
    public static var all: [MatrixLoaderID] {
        var ids: [MatrixLoaderID] = []
        ids += (1...23).map { .square($0) }
        ids += (1...20).map { .circular($0) }
        ids += (1...10).map { .hex($0) }
        ids += [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 18, 19, 20, 21].map {
            .grid3($0)
        }
        ids += (1...20).map { .triangle($0) }
        ids += FunLoader.allCases.map { .fun($0) }
        ids += [.icon]
        return ids
    }

    /// Pool id for the families managed by `MatrixLoadingPool` (all but Triangle/Icon).
    var poolID: String? {
        switch self {
        case .square(let n): return "S\(n)"
        case .circular(let n): return "C\(n)"
        case .hex(let n): return "Hex\(n)"
        case .grid3(let n): return "G3-\(n)"
        case .fun(let f): return f.poolID
        case .triangle, .icon: return nil
        }
    }
}

/// Renders one specific dot-matrix loader. This is the primary way to use a loader
/// directly — pick it by shape + index and size / color it:
///
/// ```swift
/// MatrixLoader(.hex(3), size: 28, color: .blue)
/// MatrixLoader(.triangle(5), speed: 1.4)
/// MatrixLoader(.fun(.heart), size: 32, color: .red)
/// MatrixLoader(.icon)
/// ```
///
/// Use `MatrixLoaderID.all` to enumerate every loader.
public struct MatrixLoader: View {
    private let id: MatrixLoaderID
    private let size: CGFloat
    private let dotSize: CGFloat?
    private let color: Color
    private let speed: Double
    private let muted: Bool
    private let bloom: Bool
    private let halo: Double

    public init(
        _ id: MatrixLoaderID,
        size: CGFloat = 24,
        color: Color = .primary,
        speed: Double = 1,
        dotSize: CGFloat? = nil,
        muted: Bool = false,
        bloom: Bool = false,
        halo: Double = 0
    ) {
        self.id = id
        self.size = size
        self.color = color
        self.speed = speed
        self.dotSize = dotSize
        self.muted = muted
        self.bloom = bloom
        self.halo = halo
    }

    public var body: some View {
        let dot = dotSize ?? max(2, floor(size / 6))
        switch id {
        case .icon:
            DotMatrixIcon(
                size: size, dotSize: dot, color: color, speed: speed, muted: muted,
                halo: halo, bloom: bloom)
        case .triangle(let n):
            Self.triangleView(n, props(.full, dot))
        default:
            if let poolID = id.poolID, let entry = MatrixLoadingPool.entry(id: poolID),
                case let .props(pattern, build) = entry.kind
            {
                build(props(pattern, dot))
            }
        }
    }

    private func props(_ pattern: MatrixPattern, _ dot: CGFloat) -> DotMatrixCommonProps {
        DotMatrixCommonProps(
            size: size, dotSize: dot, color: color, speed: speed, pattern: pattern,
            muted: muted, bloom: bloom, halo: halo)
    }

    @ViewBuilder
    private static func triangleView(_ n: Int, _ p: DotMatrixCommonProps) -> some View {
        switch n {
        case 1: DotmTriangle1(props: p)
        case 2: DotmTriangle2(props: p)
        case 3: DotmTriangle3(props: p)
        case 4: DotmTriangle4(props: p)
        case 5: DotmTriangle5(props: p)
        case 6: DotmTriangle6(props: p)
        case 7: DotmTriangle7(props: p)
        case 8: DotmTriangle8(props: p)
        case 9: DotmTriangle9(props: p)
        case 10: DotmTriangle10(props: p)
        case 11: DotmTriangle11(props: p)
        case 12: DotmTriangle12(props: p)
        case 13: DotmTriangle13(props: p)
        case 14: DotmTriangle14(props: p)
        case 15: DotmTriangle15(props: p)
        case 16: DotmTriangle16(props: p)
        case 17: DotmTriangle17(props: p)
        case 18: DotmTriangle18(props: p)
        case 19: DotmTriangle19(props: p)
        case 20: DotmTriangle20(props: p)
        default: EmptyView()
        }
    }
}
