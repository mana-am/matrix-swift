import SwiftUI

/// Lissajous figure-8 head + trail, 1700ms.
struct DotmSquare19: View {
    var props = DotMatrixCommonProps(pattern: .full)

    private static let STEP_COUNT: Int = 48
    private static let BASE_OPACITY: Double = 0.08
    private static let SECONDARY_TRAIL_OPACITY: Double = 0.32
    private static let PRIMARY_TRAIL_OPACITY: Double = 0.62
    private static let PEAK_OPACITY: Double = 1
    private static let CURVE_OPACITY: Double = 0.2

    private struct Point { var x: Double; var y: Double }

    private static let CURVE_SAMPLES: [Point] = (0..<96).map { i in
        let t = (Double(i) / 96.0) * .pi * 2
        return Point(x: sin(t), y: 0.58 * sin(2 * t))
    }

    private static func gridPoint(row: Int, col: Int) -> Point {
        Point(x: Double(col - 2) / 2.0, y: Double(2 - row) / 2.0)
    }

    private static func loopPoint(step: Int) -> Point {
        let t = (Double(step % STEP_COUNT) / Double(STEP_COUNT)) * .pi * 2
        return Point(x: sin(t), y: 0.58 * sin(2 * t))
    }

    private static func squaredDist(_ a: Point, _ b: Point) -> Double {
        let dx = a.x - b.x; let dy = a.y - b.y
        return dx * dx + dy * dy
    }

    private static func minCurveDistSq(_ p: Point) -> Double {
        var min = Double.infinity
        for s in CURVE_SAMPLES { let d = squaredDist(p, s); if d < min { min = d } }
        return min
    }

    private static func headInfluence(_ dot: Point, _ head: Point) -> Double {
        exp(-squaredDist(dot, head) / 0.19)
    }

    var body: some View {
        DotMatrixBase(props: props) { ctx, now in
            let dot = Self.gridPoint(row: ctx.row, col: ctx.col)

            if ctx.reducedMotion || ctx.phase == .idle {
                let curveGlow = exp(-Self.minCurveDistSq(dot) / 0.2)
                let r2 = dot.x * dot.x + dot.y * dot.y
                let centerBoost = exp(-r2 / 0.06)
                let op = Self.BASE_OPACITY + curveGlow * Self.CURVE_OPACITY + centerBoost * 0.18
                return min(Self.PEAK_OPACITY, op)
            }

            let step = steppedCycle(now: now, cycleMsBase: 1700, steps: Self.STEP_COUNT, speed: 1, active: true)
            let headA = Self.loopPoint(step: step)
            let headB = Self.loopPoint(step: step + Self.STEP_COUNT / 2)
            let trailA = Self.loopPoint(step: step - 4)
            let trailB = Self.loopPoint(step: step + Self.STEP_COUNT / 2 - 4)

            let lead = max(Self.headInfluence(dot, headA), Self.headInfluence(dot, headB))
            let trail = max(Self.headInfluence(dot, trailA), Self.headInfluence(dot, trailB))
            let r2 = dot.x * dot.x + dot.y * dot.y
            let centerPulse = exp(-r2 / 0.05) * (0.45 + 0.55 * lead)

            let op1 = Self.BASE_OPACITY + Self.SECONDARY_TRAIL_OPACITY * trail
            let op2 = Self.PRIMARY_TRAIL_OPACITY * lead + 0.16 * centerPulse
            return min(Self.PEAK_OPACITY, op1 + op2)
        }
    }
}
