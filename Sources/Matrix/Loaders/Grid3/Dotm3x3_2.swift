import SwiftUI

/// 3×3 diagonal wave, top-right → bottom-left. Mirrors `dotm-3x3-2.tsx`.
struct Dotm3x3_2: View {
    var props = DotMatrixCommonProps(speed: 1.15, pattern: .full)
    var body: some View {
        DiagonalWave3Loader(props: props, direction: .trBl)
    }
}
