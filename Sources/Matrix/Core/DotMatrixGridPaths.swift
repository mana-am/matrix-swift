import Foundation

enum DotMatrixGridPaths {
    static let N = MATRIX_SIZE
    static let CENTER = MATRIX_CENTER
    static let CELLS = MATRIX_CELLS
    static let MAX_TRBL = (MATRIX_SIZE - 1) * 2

    static func trBlPathNormFromIndex(_ index: Int) -> Double {
        let (r, c) = indexToCoord(index)
        return Double(r + (N - 1 - c)) / Double(MAX_TRBL)
    }

    private static let snakeOrder: [Int] = {
        var order = Array(repeating: 0, count: CELLS)
        var t = 0
        for row in 0..<N {
            if row % 2 == 0 {
                for col in 0..<N { order[rowMajorIndex(row, col)] = t; t += 1 }
            } else {
                for col in stride(from: N - 1, through: 0, by: -1) {
                    order[rowMajorIndex(row, col)] = t; t += 1
                }
            }
        }
        return order
    }()

    static func snakePathOrderValue(_ index: Int) -> Int { snakeOrder[index] }
    static func snakePathNormFromIndex(_ index: Int) -> Double {
        Double(snakeOrder[index]) / Double(CELLS - 1)
    }

    private static let spiralInwardOrder: [Int] = {
        var order = Array(repeating: 0, count: CELLS)
        var top = 0, bottom = N - 1, left = 0, right = N - 1
        var t = 0
        while top <= bottom && left <= right {
            for col in left...right { order[rowMajorIndex(top, col)] = t; t += 1 }
            if top + 1 <= bottom {
                for row in (top + 1)...bottom { order[rowMajorIndex(row, right)] = t; t += 1 }
            }
            if top < bottom && left <= right - 1 {
                for col in stride(from: right - 1, through: left, by: -1) {
                    order[rowMajorIndex(bottom, col)] = t; t += 1
                }
            }
            if left < right && top + 1 <= bottom - 1 {
                for row in stride(from: bottom - 1, through: top + 1, by: -1) {
                    order[rowMajorIndex(row, left)] = t; t += 1
                }
            }
            top += 1; bottom -= 1; left += 1; right -= 1
        }
        return order
    }()

    static func spiralInwardOrderValue(_ index: Int) -> Int { spiralInwardOrder[index] }
    static func spiralInwardNormFromIndex(_ index: Int) -> Double {
        Double(spiralInwardOrder[index]) / Double(CELLS - 1)
    }

    private static let outerRingClockwiseOrder: [Int] = {
        var order = Array(repeating: -1, count: CELLS)
        let coords: [(Int, Int)] = [
            (0, 0), (0, 1), (0, 2), (0, 3), (0, 4),
            (1, 4), (2, 4), (3, 4), (4, 4),
            (4, 3), (4, 2), (4, 1), (4, 0),
            (3, 0), (2, 0), (1, 0),
        ]
        for (t, (r, c)) in coords.enumerated() { order[rowMajorIndex(r, c)] = t }
        return order
    }()

    private static let middleRingAntiClockwiseOrder: [Int] = {
        var order = Array(repeating: -1, count: CELLS)
        let coords: [(Int, Int)] = [
            (1, 1), (2, 1), (3, 1), (3, 2), (3, 3), (2, 3), (1, 3), (1, 2),
        ]
        for (t, (r, c)) in coords.enumerated() { order[rowMajorIndex(r, c)] = t }
        return order
    }()

    static func outerRingClockwiseOrderValue(_ index: Int) -> Int { outerRingClockwiseOrder[index] }
    static func outerRingClockwiseNormFromIndex(_ index: Int) -> Double {
        let o = outerRingClockwiseOrder[index]
        return o >= 0 ? Double(o) / 15.0 : 0
    }

    static func middleRingAntiClockwiseOrderValue(_ index: Int) -> Int {
        middleRingAntiClockwiseOrder[index]
    }
    static func middleRingAntiClockwiseNormFromIndex(_ index: Int) -> Double {
        let o = middleRingAntiClockwiseOrder[index]
        return o >= 0 ? Double(o) / 7.0 : 0
    }

    private static let diagonalSnakeOrder: [Int] = {
        var order = Array(repeating: 0, count: CELLS)
        var t = 0
        for diagonal in 0...((N - 1) * 2) {
            let rowStart = max(0, diagonal - (N - 1))
            let rowEnd = min(N - 1, diagonal)
            if diagonal % 2 == 0 {
                for row in stride(from: rowEnd, through: rowStart, by: -1) {
                    let col = diagonal - row
                    order[rowMajorIndex(row, col)] = t; t += 1
                }
            } else {
                for row in rowStart...rowEnd {
                    let col = diagonal - row
                    order[rowMajorIndex(row, col)] = t; t += 1
                }
            }
        }
        return order
    }()

    static func diagonalSnakeOrderValue(_ index: Int) -> Int { diagonalSnakeOrder[index] }
    static func diagonalSnakeNormFromIndex(_ index: Int) -> Double {
        Double(diagonalSnakeOrder[index]) / Double(CELLS - 1)
    }

    private static let rowWaveSnakeOrder: [Int] = {
        var order = Array(repeating: 0, count: CELLS)
        let route: [(col: Int, dir: Int)] = [
            (0, -1), (2, 1), (1, -1), (3, 1), (2, -1), (4, 1),
        ]  // dir: -1 = up (row N-1..0), +1 = down (row 0..N-1)
        var t = 0
        for step in route {
            if step.dir == -1 {
                for row in stride(from: N - 1, through: 0, by: -1) {
                    order[rowMajorIndex(row, step.col)] = t; t += 1
                }
            } else {
                for row in 0..<N { order[rowMajorIndex(row, step.col)] = t; t += 1 }
            }
        }
        return order
    }()

    static let rowWaveSnakeMaxOrder: Int = rowWaveSnakeOrder.max() ?? 0
    static func rowWaveOrderValue(_ index: Int) -> Int { rowWaveSnakeOrder[index] }
    static func rowWaveNormFromIndex(_ index: Int) -> Double {
        rowWaveSnakeMaxOrder > 0 ? Double(rowWaveOrderValue(index)) / Double(rowWaveSnakeMaxOrder) : 0
    }

    static func colWaveNormFromIndex(_ index: Int) -> Double {
        let (_, c) = indexToCoord(index)
        return N > 1 ? Double(c) / Double(N - 1) : 0
    }

    static func concentricRingNormFromIndex(_ index: Int) -> Double {
        let (r, c) = indexToCoord(index)
        return Double(max(abs(r - CENTER), abs(c - CENTER))) / Double(CENTER)
    }
}
