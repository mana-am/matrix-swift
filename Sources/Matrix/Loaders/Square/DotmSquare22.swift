import SwiftUI

/// Path-wave: column wave.
struct DotmSquare22: View {
    var props = DotMatrixCommonProps(pattern: .full)
    var body: some View {
        PathWaveBase(
            props: props,
            normFn: { idx, _, _ in DotMatrixGridPaths.colWaveNormFromIndex(idx) }
        )
    }
}
