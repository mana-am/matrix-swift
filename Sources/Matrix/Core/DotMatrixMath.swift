import Foundation

enum DotMatrixMath {
    static let MAX_RADIUS: Double = (Double(MATRIX_CENTER) * Double(MATRIX_CENTER) * 2).squareRoot()

    static func polarAngle(_ index: Int) -> Double {
        let (r, c) = indexToCoord(index)
        return atan2(Double(r - MATRIX_CENTER), Double(c - MATRIX_CENTER))
    }

    static func normalizedRadius(_ index: Int) -> Double {
        let (r, c) = indexToCoord(index)
        let dr = Double(r - MATRIX_CENTER)
        let dc = Double(c - MATRIX_CENTER)
        return (dr * dr + dc * dc).squareRoot() / MAX_RADIUS
    }

    static func manhattanDistance(_ index: Int) -> Int {
        let (r, c) = indexToCoord(index)
        return abs(r - MATRIX_CENTER) + abs(c - MATRIX_CENTER)
    }

    static func harmonicPhase(_ row: Int, _ col: Int, _ a: Double, _ b: Double) -> Double {
        sin(Double(row + 1) * a + Double(col + 1) * b)
    }

    static func lissajousOffset(
        row: Int, col: Int, amplitude: Double = 2.25
    ) -> (x: Double, y: Double, phase: Double) {
        let x = sin(Double(row + 1) * 1.15 + Double(col + 1) * 2.2) * amplitude
        let y = cos(Double(row + 1) * 2.45 + Double(col + 1) * 0.95) * amplitude
        let phase = abs(sin(Double(row + 1) * 0.7 + Double(col + 1) * 1.1))
        return (x, y, phase)
    }

    static func spiralOffset(
        angle: Double, radiusNormalizedValue r: Double, amplitude: Double = 2.8
    ) -> (x: Double, y: Double, phase: Double) {
        let spin = angle + r * .pi * 2.1
        let radius = r * amplitude
        let x = cos(spin) * radius
        let y = sin(spin) * radius
        let phase = abs(sin(spin * 0.5))
        return (x, y, phase)
    }

    static func isPrime(_ value: Int) -> Bool {
        if value <= 1 { return false }
        if value == 2 { return true }
        if value % 2 == 0 { return false }
        let limit = Int(Double(value).squareRoot())
        var d = 3
        while d <= limit {
            if value % d == 0 { return false }
            d += 2
        }
        return true
    }

    @inline(__always)
    static func smoothstep01(_ edge0: Double, _ edge1: Double, _ x: Double) -> Double {
        if edge1 <= edge0 { return x >= edge1 ? 1 : 0 }
        let t = max(0, min(1, (x - edge0) / (edge1 - edge0)))
        return t * t * (3 - 2 * t)
    }

    @inline(__always)
    static func modF(_ n: Double, _ m: Double) -> Double {
        ((n.truncatingRemainder(dividingBy: m)) + m).truncatingRemainder(dividingBy: m)
    }
}
