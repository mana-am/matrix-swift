import SwiftUI

enum MatrixPattern: String, CaseIterable, Sendable {
    case full
    case diamond
    case outline
    case cross
    case rings
    case rose
    /// Mana brand letter "M" silhouette on the 5×5 grid.
    case manaM
    /// 5×5 heart silhouette — pairs well with the heartbeat keyframe.
    case heart
    /// 5×5 right-pointing arrow — used for "answer is flowing" loaders.
    case arrowRight
    /// 5×5 four-point sparkle — corners + cross, looks like ✦
    case sparkle
    /// 5×5 eye outline + iris.
    case eye
    /// 5×5 lightning bolt zigzag.
    case lightning
    /// 5×5 6-petal flower (cardinal + diagonal arms around an inner ring).
    case flower
    /// 5×5 horizontal sine-wave silhouette.
    case wave
    /// 5×5 hexagon outline.
    case hexagon
}

enum MatrixPhase: Sendable {
    case idle
    case loadingRipple
    case collapse
    case hoverRipple
}

struct DotAnimationContext {
    let index: Int
    let row: Int
    let col: Int
    let distanceFromCenter: Double
    let polarAngle: Double
    let radiusNormalized: Double
    let manhattanDistance: Int
    let phase: MatrixPhase
    let isActive: Bool
    let reducedMotion: Bool
}

struct DotAnimationState {
    var opacity: Double
}

let MATRIX_SIZE = 5
let MATRIX_CENTER = MATRIX_SIZE / 2
let MATRIX_CELLS = MATRIX_SIZE * MATRIX_SIZE

@inline(__always)
func rowMajorIndex(_ row: Int, _ col: Int, size: Int = MATRIX_SIZE) -> Int {
    row * size + col
}

@inline(__always)
func indexToCoord(_ index: Int, size: Int = MATRIX_SIZE) -> (row: Int, col: Int) {
    (row: index / size, col: index % size)
}
