import SwiftUI

/// Triple Spoke — three radial spokes at 120° rotate around the center; a
/// faint outer pulse adds a "shell" sheen on the outer ring. Mirrors
/// upstream `dotm-hex-2.tsx`.
public struct DotmHex2: View {
    var props = DotMatrixCommonProps(speed: 1.7, pattern: .full)
    init(props: DotMatrixCommonProps) { self.props = props }

    /// Source-parity ergonomic init — mirrors `<DotmHex2 size=… />` upstream. The
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


    private static let spokeWidth: Double = 0.34
    private static let baseOp: Double = 0.08
    private static let midOp: Double = 0.44
    private static let highOp: Double = 0.98

    public var body: some View {
        DotMatrixHexBase(props: props, timing: .cycle(cycleMsBase: 1500)) { row, col, phase in
            let polar = HexCell.polar(row: row, col: col)
            if polar.radius < 0.01 {
                return Self.midOp + sin(phase * .pi * 2) * 0.18
            }
            let rotation = phase * .pi * 2
            let a = dmHexAngularDistance(polar.angle, rotation)
            let b = dmHexAngularDistance(polar.angle, rotation + (.pi * 2 / 3))
            let c = dmHexAngularDistance(polar.angle, rotation + (.pi * 4 / 3))
            let nearest = min(a, min(b, c))
            let spokeGlow = max(0, 1 - nearest / Self.spokeWidth)
            let outerPulse = 0.5 + 0.5 * sin(phase * .pi * 2 - polar.radius * 2.2)
            let shellLift = polar.radius > 1.7 ? outerPulse * 0.24 : 0
            return min(Self.highOp, Self.baseOp + spokeGlow * 0.78 + shellLift)
        }
    }
}
