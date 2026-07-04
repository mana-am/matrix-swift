import Foundation

/// Continuous [0,1) phase given wall-clock time, mirroring React `useCyclePhase`.
@inline(__always)
func cyclePhase(now: TimeInterval, cycleMsBase: Double, speed: Double, active: Bool) -> Double {
    guard active else { return 0 }
    let safeSpeed = speed > 0 ? speed : 1
    let raw = cycleMsBase / safeSpeed
    let cycleMs = (raw > 0 && raw.isFinite) ? raw : 1000
    let cycleSec = cycleMs / 1000.0
    let elapsed = (now.truncatingRemainder(dividingBy: cycleSec) + cycleSec)
        .truncatingRemainder(dividingBy: cycleSec)
    return elapsed / cycleSec
}
