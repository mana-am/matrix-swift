import Foundation

enum DotMatrixPatterns {
    static let full: [Int] = (0..<MATRIX_CELLS).map { $0 }

    static let diamond: [Int] = full.filter { idx in
        let (r, c) = indexToCoord(idx)
        return abs(r - MATRIX_CENTER) + abs(c - MATRIX_CENTER) <= 2
    }

    static let outline: [Int] = full.filter { idx in
        let (r, c) = indexToCoord(idx)
        return r == 0 || r == MATRIX_SIZE - 1 || c == 0 || c == MATRIX_SIZE - 1
    }

    static let cross: [Int] = full.filter { idx in
        let (r, c) = indexToCoord(idx)
        return r == MATRIX_CENTER || c == MATRIX_CENTER
    }

    static let rings: [Int] = full.filter { idx in
        let (r, c) = indexToCoord(idx)
        let radius = (Double(r - MATRIX_CENTER) * Double(r - MATRIX_CENTER)
            + Double(c - MATRIX_CENTER) * Double(c - MATRIX_CENTER)).squareRoot()
        let rounded = Int(radius.rounded())
        return rounded == 1 || rounded == 2
    }

    static let rose: [Int] = full.filter { idx in
        let (r, c) = indexToCoord(idx)
        let dx = Double(c - MATRIX_CENTER)
        let dy = Double(r - MATRIX_CENTER)
        let angle = atan2(dy, dx)
        let radius = (dx * dx + dy * dy).squareRoot()
        let roseValue = abs(sin(3 * angle))
        return roseValue > 0.6 && radius >= 1
    }

    /// Mana "M" silhouette:
    ///   1 0 0 0 1
    ///   1 1 0 1 1
    ///   1 0 1 0 1
    ///   1 0 0 0 1
    ///   1 0 0 0 1
    static let manaM: [Int] = [0, 4, 5, 6, 8, 9, 10, 12, 14, 15, 19, 20, 24]

    /// Heart:
    ///   0 1 0 1 0
    ///   1 1 1 1 1
    ///   1 1 1 1 1
    ///   0 1 1 1 0
    ///   0 0 1 0 0
    static let heart: [Int] = [
        1, 3,
        5, 6, 7, 8, 9,
        10, 11, 12, 13, 14,
        16, 17, 18,
        22,
    ]

    /// Right-pointing arrow (head + shaft):
    ///   0 0 1 0 0
    ///   0 0 1 1 0
    ///   1 1 1 1 1
    ///   0 0 1 1 0
    ///   0 0 1 0 0
    static let arrowRight: [Int] = [
        2,
        7, 8,
        10, 11, 12, 13, 14,
        17, 18,
        22,
    ]

    /// Sparkle ✦ (corners + center cross):
    ///   1 0 1 0 1
    ///   0 0 1 0 0
    ///   1 1 1 1 1
    ///   0 0 1 0 0
    ///   1 0 1 0 1
    static let sparkle: [Int] = [
        0, 2, 4,
        7,
        10, 11, 12, 13, 14,
        17,
        20, 22, 24,
    ]

    /// Eye outline + iris:
    ///   0 1 1 1 0
    ///   1 0 0 0 1
    ///   1 0 1 0 1
    ///   1 0 0 0 1
    ///   0 1 1 1 0
    static let eye: [Int] = [
        1, 2, 3,
        5, 9,
        10, 12, 14,
        15, 19,
        21, 22, 23,
    ]

    /// Lightning bolt zigzag:
    ///   0 0 1 1 0
    ///   0 1 1 0 0
    ///   1 1 1 0 0
    ///   0 0 1 1 0
    ///   0 0 0 1 1
    static let lightning: [Int] = [
        2, 3,
        6, 7,
        10, 11, 12,
        17, 18,
        23, 24,
    ]

    /// 6-petal flower (cardinal arms + diagonal arms + inner cross):
    ///   0 0 1 0 0
    ///   1 0 1 0 1
    ///   0 1 1 1 0
    ///   1 0 1 0 1
    ///   0 0 1 0 0
    static let flower: [Int] = [
        2,
        5, 7, 9,
        11, 12, 13,
        15, 17, 19,
        22,
    ]

    /// Horizontal sine wave silhouette:
    ///   0 0 0 0 0
    ///   0 1 1 0 0
    ///   1 1 1 1 1
    ///   0 0 1 1 0
    ///   0 0 0 0 0
    static let wave: [Int] = [
        6, 7,
        10, 11, 12, 13, 14,
        17, 18,
    ]

    /// Hexagon outline:
    ///   0 1 1 1 0
    ///   1 0 0 0 1
    ///   1 0 0 0 1
    ///   1 0 0 0 1
    ///   0 1 1 1 0
    static let hexagon: [Int] = [
        1, 2, 3,
        5, 9,
        10, 14,
        15, 19,
        21, 22, 23,
    ]

    static func indexes(for pattern: MatrixPattern) -> [Int] {
        switch pattern {
        case .full: return full
        case .diamond: return diamond
        case .outline: return outline
        case .cross: return cross
        case .rings: return rings
        case .rose: return rose
        case .manaM: return manaM
        case .heart: return heart
        case .arrowRight: return arrowRight
        case .sparkle: return sparkle
        case .eye: return eye
        case .lightning: return lightning
        case .flower: return flower
        case .wave: return wave
        case .hexagon: return hexagon
        }
    }

    static func mask(for pattern: MatrixPattern) -> [Bool] {
        var arr = Array(repeating: false, count: MATRIX_CELLS)
        for i in indexes(for: pattern) { arr[i] = true }
        return arr
    }
}

@inline(__always)
func distanceFromCenter5x5(_ index: Int) -> Double {
    let (r, c) = indexToCoord(index)
    let dr = Double(r - MATRIX_CENTER)
    let dc = Double(c - MATRIX_CENTER)
    return (dr * dr + dc * dc).squareRoot()
}

@inline(__always)
func rowDistance5x5(_ index: Int) -> Int {
    abs(indexToCoord(index).row - MATRIX_CENTER)
}
