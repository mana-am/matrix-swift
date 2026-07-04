import Foundation

/// Source-side triplet — every loader writes opacities assuming this scale.
/// `remapOpacityToTriplet` re-interpolates them onto a user-provided triplet.
private let SOURCE_BASE = 0.08
private let SOURCE_MID = 0.34
private let SOURCE_PEAK = 0.94

@inline(__always)
private func clamp01(_ v: Double) -> Double {
    if !v.isFinite { return 0 }
    return min(1, max(0, v))
}

@inline(__always)
private func lerp(_ a: Double, _ b: Double, _ t: Double) -> Double { a + (b - a) * t }

@inline(__always)
private func normalize(_ v: Double, _ a: Double, _ b: Double) -> Double {
    let span = b - a
    if abs(span) < .ulpOfOne { return 0 }
    return clamp01((v - a) / span)
}

func remapOpacityToTriplet(
    _ opacity: Double,
    base: Double? = nil,
    mid: Double? = nil,
    peak: Double? = nil
) -> Double {
    if !opacity.isFinite { return opacity }
    let hasOverrides = base != nil || mid != nil || peak != nil
    if !hasOverrides { return clamp01(opacity) }

    let targetBase = base.map(clamp01) ?? SOURCE_BASE
    let targetMid = mid.map(clamp01) ?? SOURCE_MID
    let targetPeak = peak.map(clamp01) ?? SOURCE_PEAK

    let safe = clamp01(opacity)
    if safe <= SOURCE_BASE {
        return clamp01(lerp(0, targetBase, normalize(safe, 0, SOURCE_BASE)))
    }
    if safe <= SOURCE_MID {
        return clamp01(lerp(targetBase, targetMid, normalize(safe, SOURCE_BASE, SOURCE_MID)))
    }
    if safe <= SOURCE_PEAK {
        return clamp01(lerp(targetMid, targetPeak, normalize(safe, SOURCE_MID, SOURCE_PEAK)))
    }
    return clamp01(lerp(targetPeak, 1, normalize(safe, SOURCE_PEAK, 1)))
}
