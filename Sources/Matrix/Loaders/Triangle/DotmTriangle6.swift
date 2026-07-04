import SwiftUI

/// Triangle 6 — braille-style fill: a single wave front sweeps the six braille
/// dots (intro), then the whole glyph blinks, then fades and resets. Cycle
/// (3000ms). Mirrors `dotm-triangle-6.tsx`.
struct DotmTriangle6: View {
    var props = DotMatrixCommonProps(size: 30, dotSize: 4, pattern: .full)

    private static let LOW_OPACITY = 0.07
    private static let MID_OPACITY = 0.36
    private static let HIGH_OPACITY = 0.96
    private static let WAVE_HALF = 0.82
    private static let INTRO_PHASE = 0.52
    private static let BLINK_PHASE = 0.36
    private static let RESET_PHASE = 0.12

    // ISO braille dot numbering (same as DotmSquare9): D1..D6.
    private static let D1 = 0x01, D2 = 0x02, D3 = 0x04, D4 = 0x08, D5 = 0x10, D6 = 0x20

    private static func smoothstep01(_ edge0: Double, _ edge1: Double, _ x: Double) -> Double {
        if edge1 <= edge0 { return x >= edge1 ? 1 : 0 }
        let t = max(0, min(1, (x - edge0) / (edge1 - edge0)))
        return t * t * (3 - 2 * t)
    }

    /// Six fills (D1..D6 order) from a single traveling wave front.
    private static func waveFills(_ introT: Double) -> [Double] {
        let waveCenter = -WAVE_HALF + introT * (5 + 2 * WAVE_HALF)
        return (0...5).map { i in
            smoothstep01(Double(i) - WAVE_HALF, Double(i) + WAVE_HALF, waveCenter)
        }
    }

    /// Triangle cell → braille bit, or nil for accent cells.
    private static func brailleBit(_ row: Int, _ col: Int) -> Int? {
        switch (row, col) {
        case (2, 2): return D1
        case (3, 1): return D2
        case (4, 0): return D3
        case (2, 4): return D4
        case (3, 5): return D5
        case (4, 6): return D6
        default: return nil
        }
    }

    private static func fillIndex(_ bit: Int) -> Int {
        switch bit {
        case D1: return 0
        case D2: return 1
        case D3: return 2
        case D4: return 3
        case D5: return 4
        case D6: return 5
        default: return 0
        }
    }

    private static func meanFills(_ indices: [Int], _ fills: [Double]) -> Double {
        var s = 0.0
        for i in indices { s += (i < fills.count ? fills[i] : 0) }
        return s / Double(indices.count)
    }

    private static func opacityForCell(
        _ row: Int, _ col: Int, _ fills: [Double], _ blinkMul: Double, _ resetMul: Double
    ) -> Double {
        func lift(_ base: Double) -> Double {
            LOW_OPACITY + (base - LOW_OPACITY) * blinkMul * resetMul
        }

        if let bit = brailleBit(row, col) {
            let idx = fillIndex(bit)
            let raw = LOW_OPACITY + (HIGH_OPACITY - LOW_OPACITY) * (idx < fills.count ? fills[idx] : 0)
            return lift(raw)
        }

        if row == 1 && col == 3 {
            let m = meanFills([0, 3], fills)
            let raw =
                LOW_OPACITY + (HIGH_OPACITY - LOW_OPACITY) * m * 0.92
                + (MID_OPACITY - LOW_OPACITY) * (1 - m) * 0.35
            return lift(min(HIGH_OPACITY, raw))
        }

        if row == 3 && col == 3 {
            let m = meanFills([0, 1, 2, 3, 4, 5], fills)
            let raw =
                LOW_OPACITY + (HIGH_OPACITY - LOW_OPACITY) * m * 0.88
                + (MID_OPACITY - LOW_OPACITY) * (1 - m) * 0.4
            return lift(min(HIGH_OPACITY, raw))
        }

        if row == 4 && col == 2 {
            let m = meanFills([1, 2], fills)
            let raw = LOW_OPACITY + (MID_OPACITY + 0.28 - LOW_OPACITY) * m
            return lift(raw)
        }
        if row == 4 && col == 4 {
            let m = meanFills([4, 5], fills)
            let raw = LOW_OPACITY + (MID_OPACITY + 0.28 - LOW_OPACITY) * m
            return lift(raw)
        }

        return LOW_OPACITY
    }

    private static func cycleParams(_ phase: Double) -> (fills: [Double], blinkMul: Double, resetMul: Double) {
        if phase < INTRO_PHASE {
            let introT = phase / INTRO_PHASE
            return (waveFills(introT), 1, 1)
        }
        if phase < INTRO_PHASE + BLINK_PHASE {
            let bt = (phase - INTRO_PHASE) / BLINK_PHASE
            let on = Int(floor(bt * 4)) % 2 == 0
            return ([1, 1, 1, 1, 1, 1], on ? 1 : 0.08, 1)
        }
        let rt = (phase - INTRO_PHASE - BLINK_PHASE) / RESET_PHASE
        let resetMul = 1 - smoothstep01(0, 1, rt)
        return ([1, 1, 1, 1, 1, 1], 1, resetMul)
    }

    var body: some View {
        DotMatrixTriangleBase(props: props) { row, col, now, active in
            let params: (fills: [Double], blinkMul: Double, resetMul: Double)
            if !active {
                params = ([0.55, 0.55, 0.55, 0.55, 0.55, 0.55], 1, 1)
            } else {
                let phase = cyclePhase(now: now, cycleMsBase: 3000, speed: 1, active: true)
                params = Self.cycleParams(phase)
            }
            return Self.opacityForCell(row, col, params.fills, params.blinkMul, params.resetMul)
        }
    }
}
