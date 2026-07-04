import SwiftUI

/// 3×3 diagonal wave, top-left → bottom-right. Mirrors `dotm-3x3-3.tsx`.
struct Dotm3x3_3: View {
    var props = DotMatrixCommonProps(speed: 1.15, pattern: .full)
    var body: some View {
        DiagonalWave3Loader(props: props, direction: .tlBr)
    }
}
