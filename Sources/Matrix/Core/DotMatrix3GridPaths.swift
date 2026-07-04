import Foundation

/// 3×3 path/order helpers. Mirrors `loaders/core/grid-paths-3.ts`.
/// Orders are precomputed once (mirroring the module-level constants upstream).
enum DotMatrix3GridPaths {
    private static let N = DotMatrix3.SIZE          // 3
    private static let CELLS = DotMatrix3.CELLS     // 9
    private static let MAX_DIAGONAL = (DotMatrix3.SIZE - 1) * 2   // 4

    // MARK: - Diagonal wavefronts

    enum DiagonalDirection { case trBl, tlBr, brTl, blTr }

    static func trBlNorm(_ index: Int) -> Double {
        let c = DotMatrix3.indexToCoord(index)
        return Double(c.row + (N - 1 - c.col)) / Double(MAX_DIAGONAL)
    }

    static func tlBrNorm(_ index: Int) -> Double {
        let c = DotMatrix3.indexToCoord(index)
        return Double(c.row + c.col) / Double(MAX_DIAGONAL)
    }

    static func brTlNorm(_ index: Int) -> Double {
        let c = DotMatrix3.indexToCoord(index)
        return Double(MAX_DIAGONAL - c.row - c.col) / Double(MAX_DIAGONAL)
    }

    static func blTrNorm(_ index: Int) -> Double {
        let c = DotMatrix3.indexToCoord(index)
        return Double(MAX_DIAGONAL - c.row - (N - 1 - c.col)) / Double(MAX_DIAGONAL)
    }

    static func diagonalNorm(_ index: Int, _ direction: DiagonalDirection) -> Double {
        switch direction {
        case .trBl: return trBlNorm(index)
        case .tlBr: return tlBrNorm(index)
        case .brTl: return brTlNorm(index)
        case .blTr: return blTrNorm(index)
        }
    }

    // MARK: - Snake (boustrophedon)

    private static let snakeOrder: [Int] = {
        var order = [Int](repeating: 0, count: CELLS)
        var t = 0
        for row in 0..<N {
            if row % 2 == 0 {
                for col in 0..<N { order[DotMatrix3.rowMajorIndex(row, col)] = t; t += 1 }
            } else {
                for col in stride(from: N - 1, through: 0, by: -1) {
                    order[DotMatrix3.rowMajorIndex(row, col)] = t; t += 1
                }
            }
        }
        return order
    }()

    static func snakeOrderValue(_ index: Int) -> Int { snakeOrder[index] }
    static func snakeNorm(_ index: Int) -> Double { Double(snakeOrder[index]) / Double(CELLS - 1) }

    // MARK: - Spiral inward

    private static let spiralInwardOrder: [Int] = {
        var order = [Int](repeating: 0, count: CELLS)
        var top = 0, bottom = N - 1, left = 0, right = N - 1, t = 0
        while top <= bottom && left <= right {
            for col in left...right { order[DotMatrix3.rowMajorIndex(top, col)] = t; t += 1 }
            if top + 1 <= bottom {
                for row in (top + 1)...bottom { order[DotMatrix3.rowMajorIndex(row, right)] = t; t += 1 }
            }
            if top < bottom && left <= right - 1 {
                for col in stride(from: right - 1, through: left, by: -1) {
                    order[DotMatrix3.rowMajorIndex(bottom, col)] = t; t += 1
                }
            }
            if left < right && (top + 1) <= (bottom - 1) {
                for row in stride(from: bottom - 1, through: top + 1, by: -1) {
                    order[DotMatrix3.rowMajorIndex(row, left)] = t; t += 1
                }
            }
            top += 1; bottom -= 1; left += 1; right -= 1
        }
        return order
    }()

    static func spiralInwardOrderValue(_ index: Int) -> Int { spiralInwardOrder[index] }
    static func spiralInwardNorm(_ index: Int) -> Double {
        Double(spiralInwardOrder[index]) / Double(CELLS - 1)
    }

    // MARK: - Outer ring clockwise (8 perimeter cells; center = -1)

    private static let outerRingClockwiseOrder: [Int] = {
        var order = [Int](repeating: -1, count: CELLS)
        let path: [(Int, Int)] = [
            (0, 0), (0, 1), (0, 2), (1, 2), (2, 2), (2, 1), (2, 0), (1, 0),
        ]
        for (step, rc) in path.enumerated() {
            order[DotMatrix3.rowMajorIndex(rc.0, rc.1)] = step
        }
        return order
    }()

    static func outerRingClockwiseOrderValue(_ index: Int) -> Int { outerRingClockwiseOrder[index] }
    static func outerRingClockwiseNorm(_ index: Int) -> Double {
        let order = outerRingClockwiseOrder[index]
        return order < 0 ? 0 : Double(order) / 7.0
    }

    // MARK: - Center / row / col

    static func isCenterCell(row: Int, col: Int) -> Bool {
        row == DotMatrix3.CENTER && col == DotMatrix3.CENTER
    }

    static func rowWaveNorm(_ row: Int) -> Double { Double(row) / Double(N - 1) }
    static func colWaveNorm(_ col: Int) -> Double { Double(col) / Double(N - 1) }
    static func colWaveNormReverse(_ col: Int) -> Double { Double(N - 1 - col) / Double(N - 1) }

    /// Triplet blend for path-position idle previews — base → mid → peak.
    static func pathOpacityFromNorm(
        _ norm: Double, base: Double = 0.06, mid: Double = 0.38, peak: Double = 0.88
    ) -> Double {
        let t = min(1, max(0, norm))
        if t <= 0.5 {
            return base + (t / 0.5) * (mid - base)
        }
        return mid + ((t - 0.5) / 0.5) * (peak - mid)
    }
}
