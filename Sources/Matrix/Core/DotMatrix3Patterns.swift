import Foundation

/// 3×3 grid geometry & pattern masks. Mirrors `loaders/core/patterns-3.ts`.
/// Kept separate from the 5×5 helpers in `DotMatrixPatterns` / `DotMatrixMath`
/// so the 3×3 loaders (`Dotm3x3_*`) don't accidentally borrow 5×5 index math.
enum DotMatrix3 {
    static let SIZE = 3
    static let CENTER = SIZE / 2            // 1
    static let CELLS = SIZE * SIZE          // 9
    /// hypot(floor(SIZE/2), floor(SIZE/2)) = √2 — used to normalize radius.
    static let MAX_RADIUS: Double = (2.0).squareRoot()

    @inline(__always)
    static func rowMajorIndex(_ row: Int, _ col: Int) -> Int { row * SIZE + col }

    @inline(__always)
    static func indexToCoord(_ index: Int) -> (row: Int, col: Int) {
        (row: index / SIZE, col: index % SIZE)
    }

    @inline(__always)
    static func distanceFromCenter(_ index: Int) -> Double {
        let c = indexToCoord(index)
        return hypot(Double(c.row - CENTER), Double(c.col - CENTER))
    }

    @inline(__always)
    static func manhattanDistance(_ index: Int) -> Int {
        let c = indexToCoord(index)
        return abs(c.row - CENTER) + abs(c.col - CENTER)
    }

    /// `atan2(row - center, col - center)` — matches `dot-matrix-3-base.tsx`.
    @inline(__always)
    static func polarAngle(_ index: Int) -> Double {
        let c = indexToCoord(index)
        return atan2(Double(c.row - CENTER), Double(c.col - CENTER))
    }

    @inline(__always)
    static func radiusNormalized(_ index: Int) -> Double {
        distanceFromCenter(index) / MAX_RADIUS
    }

    // MARK: - Pattern index sets

    private static let FULL: [Int] = Array(0..<CELLS)

    private static let OUTLINE: [Int] = FULL.filter { idx in
        let c = indexToCoord(idx)
        return c.row == 0 || c.row == SIZE - 1 || c.col == 0 || c.col == SIZE - 1
    }

    private static let DIAMOND: [Int] = FULL.filter { idx in
        let c = indexToCoord(idx)
        return abs(c.row - CENTER) + abs(c.col - CENTER) <= 1
    }

    private static let CROSS: [Int] = FULL.filter { idx in
        let c = indexToCoord(idx)
        return c.row == CENTER || c.col == CENTER
    }

    private static let RINGS: [Int] = FULL.filter { idx in
        let c = indexToCoord(idx)
        return Int((hypot(Double(c.row - CENTER), Double(c.col - CENTER))).rounded()) == 1
    }

    private static let ROSE: [Int] = FULL.filter { idx in
        let c = indexToCoord(idx)
        let dx = Double(c.col - CENTER)
        let dy = Double(c.row - CENTER)
        let angle = atan2(dy, dx)
        let radius = hypot(dx, dy)
        let rose = abs(sin(3 * angle))
        return rose > 0.55 && radius >= 0.75
    }

    /// `getPattern3Indexes` — only the 6 patterns 3×3 supports upstream; any
    /// other `MatrixPattern` (heart / manaM / …, unused by 3×3 loaders) falls
    /// back to the full grid.
    static func indexes(for pattern: MatrixPattern) -> [Int] {
        switch pattern {
        case .full:    return FULL
        case .outline: return OUTLINE
        case .diamond: return DIAMOND
        case .cross:   return CROSS
        case .rings:   return RINGS
        case .rose:    return ROSE
        default:       return FULL
        }
    }

    /// Boolean mask over the 9 cells for a pattern.
    static func mask(for pattern: MatrixPattern) -> [Bool] {
        var m = [Bool](repeating: false, count: CELLS)
        for i in indexes(for: pattern) { m[i] = true }
        return m
    }
}
