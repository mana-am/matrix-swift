import SwiftUI

/// 3×3 diagonal wave, bottom-left → top-right. Mirrors `dotm-3x3-5.tsx`.
struct Dotm3x3_5: View {
    var props = DotMatrixCommonProps(speed: 1.15, pattern: .full)
    var body: some View {
        DiagonalWave3Loader(props: props, direction: .blTr)
    }
}
