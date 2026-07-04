import SwiftUI

/// 3×3 diagonal wave, bottom-right → top-left. Mirrors `dotm-3x3-4.tsx`.
struct Dotm3x3_4: View {
    var props = DotMatrixCommonProps(speed: 1.15, pattern: .full)
    var body: some View {
        DiagonalWave3Loader(props: props, direction: .brTl)
    }
}
