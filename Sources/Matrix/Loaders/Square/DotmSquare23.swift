import SwiftUI

/// Path-wave: concentric rings.
struct DotmSquare23: View {
    var props = DotMatrixCommonProps(pattern: .full)
    var body: some View {
        PathWaveBase(
            props: props,
            normFn: { idx, _, _ in DotMatrixGridPaths.concentricRingNormFromIndex(idx) }
        )
    }
}
