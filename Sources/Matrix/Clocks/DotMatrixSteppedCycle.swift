import Foundation

/// Integer step in [0, steps) for wall-clock time, mirroring React `useSteppedCycle`.
@inline(__always)
func steppedCycle(
    now: TimeInterval,
    cycleMsBase: Double,
    steps: Int,
    speed: Double,
    active: Bool,
    idleStep: Int = 0
) -> Int {
    guard active else { return idleStep }
    let safeSteps = max(1, steps)
    let safeSpeed = speed > 0 ? speed : 1
    let cycleMs = cycleMsBase / safeSpeed
    let cycleSec = cycleMs / 1000.0
    let stepSec = cycleSec / Double(safeSteps)
    if stepSec <= 0 || !stepSec.isFinite { return idleStep }
    let elapsed = max(0, now)
    let mod = (elapsed.truncatingRemainder(dividingBy: cycleSec) + cycleSec)
        .truncatingRemainder(dividingBy: cycleSec)
    return Int(floor(mod / stepSec)) % safeSteps
}
