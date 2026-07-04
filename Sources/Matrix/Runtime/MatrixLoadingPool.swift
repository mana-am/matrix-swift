import SwiftUI

/// One entry in the `MatrixLoadingPool` random pool. Each entry knows whether it
/// drives a generic `props:`-based loader (Square / Circular / shape-agnostic Fun /
/// shape-locked Fun) or the special `DotMatrixIcon` (which has a non-`props:`
/// init signature). Shape-locked Fun loaders carry their required `MatrixPattern`
/// in the `.props` case so the pool always feeds them the right silhouette.
struct LoaderEntry {
    enum Kind {
        /// A loader that takes `DotMatrixCommonProps`. The bound `MatrixPattern`
        /// is the silhouette to render — `.full` for shape-agnostic loaders,
        /// the locked pattern (e.g. `.heart`) for shape-locked Fun loaders.
        case props(MatrixPattern, (DotMatrixCommonProps) -> AnyView)
        /// `DotMatrixIcon` — handled separately because its init is not props-based.
        case icon
    }

    let id: String   // for logging / diagnostics
    let kind: Kind
}

/// All 92 loaders that can render in chat loading slots, plus a deterministic
/// `pick(seed:)` selector. The pool is exhaustive (matches the Debug Gallery)
/// so every loader gets a chance to appear in chat — per the user's "use all"
/// decision. The Triangle family (20 loaders) is intentionally **not** pooled —
/// it's translated for parity with upstream but unused in Mana iOS, visible only
/// in the Debug Gallery.
enum MatrixLoadingPool {
    static let all: [LoaderEntry] = [
        // MARK: Square (23) — all shape-agnostic
        .init(id: "S1",  kind: .props(.full, { AnyView(DotmSquare1(props: $0))  })),
        .init(id: "S2",  kind: .props(.full, { AnyView(DotmSquare2(props: $0))  })),
        .init(id: "S3",  kind: .props(.full, { AnyView(DotmSquare3(props: $0))  })),
        .init(id: "S4",  kind: .props(.full, { AnyView(DotmSquare4(props: $0))  })),
        .init(id: "S5",  kind: .props(.full, { AnyView(DotmSquare5(props: $0))  })),
        .init(id: "S6",  kind: .props(.full, { AnyView(DotmSquare6(props: $0))  })),
        .init(id: "S7",  kind: .props(.full, { AnyView(DotmSquare7(props: $0))  })),
        .init(id: "S8",  kind: .props(.full, { AnyView(DotmSquare8(props: $0))  })),
        .init(id: "S9",  kind: .props(.full, { AnyView(DotmSquare9(props: $0))  })),
        .init(id: "S10", kind: .props(.full, { AnyView(DotmSquare10(props: $0)) })),
        .init(id: "S11", kind: .props(.full, { AnyView(DotmSquare11(props: $0)) })),
        .init(id: "S12", kind: .props(.full, { AnyView(DotmSquare12(props: $0)) })),
        .init(id: "S13", kind: .props(.full, { AnyView(DotmSquare13(props: $0)) })),
        .init(id: "S14", kind: .props(.full, { AnyView(DotmSquare14(props: $0)) })),
        .init(id: "S15", kind: .props(.full, { AnyView(DotmSquare15(props: $0)) })),
        .init(id: "S16", kind: .props(.full, { AnyView(DotmSquare16(props: $0)) })),
        .init(id: "S17", kind: .props(.full, { AnyView(DotmSquare17(props: $0)) })),
        .init(id: "S18", kind: .props(.full, { AnyView(DotmSquare18(props: $0)) })),
        .init(id: "S19", kind: .props(.full, { AnyView(DotmSquare19(props: $0)) })),
        .init(id: "S20", kind: .props(.full, { AnyView(DotmSquare20(props: $0)) })),
        .init(id: "S21", kind: .props(.full, { AnyView(DotmSquare21(props: $0)) })),
        .init(id: "S22", kind: .props(.full, { AnyView(DotmSquare22(props: $0)) })),
        .init(id: "S23", kind: .props(.full, { AnyView(DotmSquare23(props: $0)) })),

        // MARK: Circular (20) — all shape-agnostic; circle-mask handled inside the loader
        .init(id: "C1",  kind: .props(.full, { AnyView(DotmCircular1(props: $0))  })),
        .init(id: "C2",  kind: .props(.full, { AnyView(DotmCircular2(props: $0))  })),
        .init(id: "C3",  kind: .props(.full, { AnyView(DotmCircular3(props: $0))  })),
        .init(id: "C4",  kind: .props(.full, { AnyView(DotmCircular4(props: $0))  })),
        .init(id: "C5",  kind: .props(.full, { AnyView(DotmCircular5(props: $0))  })),
        .init(id: "C6",  kind: .props(.full, { AnyView(DotmCircular6(props: $0))  })),
        .init(id: "C7",  kind: .props(.full, { AnyView(DotmCircular7(props: $0))  })),
        .init(id: "C8",  kind: .props(.full, { AnyView(DotmCircular8(props: $0))  })),
        .init(id: "C9",  kind: .props(.full, { AnyView(DotmCircular9(props: $0))  })),
        .init(id: "C10", kind: .props(.full, { AnyView(DotmCircular10(props: $0)) })),
        .init(id: "C11", kind: .props(.full, { AnyView(DotmCircular11(props: $0)) })),
        .init(id: "C12", kind: .props(.full, { AnyView(DotmCircular12(props: $0)) })),
        .init(id: "C13", kind: .props(.full, { AnyView(DotmCircular13(props: $0)) })),
        .init(id: "C14", kind: .props(.full, { AnyView(DotmCircular14(props: $0)) })),
        .init(id: "C15", kind: .props(.full, { AnyView(DotmCircular15(props: $0)) })),
        .init(id: "C16", kind: .props(.full, { AnyView(DotmCircular16(props: $0)) })),
        .init(id: "C17", kind: .props(.full, { AnyView(DotmCircular17(props: $0)) })),
        .init(id: "C18", kind: .props(.full, { AnyView(DotmCircular18(props: $0)) })),
        .init(id: "C19", kind: .props(.full, { AnyView(DotmCircular19(props: $0)) })),
        .init(id: "C20", kind: .props(.full, { AnyView(DotmCircular20(props: $0)) })),

        // MARK: Fun shape-locked (9) — pattern is the silhouette they animate
        .init(id: "Heart",     kind: .props(.heart,      { AnyView(DotmFunHeart(props: $0))     })),
        .init(id: "ManaM",     kind: .props(.manaM,      { AnyView(DotmFunManaM(props: $0))     })),
        .init(id: "Arrow",     kind: .props(.arrowRight, { AnyView(DotmFunArrow(props: $0))     })),
        .init(id: "Sparkle",   kind: .props(.sparkle,    { AnyView(DotmFunSparkle(props: $0))   })),
        .init(id: "Eye",       kind: .props(.eye,        { AnyView(DotmFunEye(props: $0))       })),
        .init(id: "Lightning", kind: .props(.lightning,  { AnyView(DotmFunLightning(props: $0)) })),
        .init(id: "Flower",    kind: .props(.flower,     { AnyView(DotmFunFlower(props: $0))    })),
        .init(id: "Wave",      kind: .props(.wave,       { AnyView(DotmFunWaveShape(props: $0)) })),
        .init(id: "Hexagon",   kind: .props(.hexagon,    { AnyView(DotmFunHexagon(props: $0))   })),

        // MARK: Fun motion-only (9) — full grid, no silhouette dependency
        .init(id: "Ink",       kind: .props(.full, { AnyView(DotmFunInkBleed(props: $0))  })),
        .init(id: "Tokens",    kind: .props(.full, { AnyView(DotmFunTokenFall(props: $0)) })),
        .init(id: "Breathing", kind: .props(.full, { AnyView(DotmFunBreathing(props: $0)) })),
        .init(id: "WaveBend",  kind: .props(.full, { AnyView(DotmFunWaveBend(props: $0))  })),
        .init(id: "Snake",     kind: .props(.full, { AnyView(DotmFunSnake(props: $0))     })),
        .init(id: "Confetti",  kind: .props(.full, { AnyView(DotmFunConfetti(props: $0))  })),
        .init(id: "Shimmer",   kind: .props(.full, { AnyView(DotmFunShimmer(props: $0))   })),
        .init(id: "Pulse",     kind: .props(.full, { AnyView(DotmFunPulseRing(props: $0)) })),
        .init(id: "Cursor",    kind: .props(.full, { AnyView(DotmFunCursor(props: $0))    })),

        // MARK: Hex (10) — hex grid (5 rows of 3-4-5-4-3 = 19 cells).
        // Pattern is unused for hex (the hex base owns its own layout), so
        // we pass `.full` as a no-op to satisfy the `LoaderEntry` shape.
        .init(id: "Hex1",   kind: .props(.full, { AnyView(DotmHex1(props: $0))  })),
        .init(id: "Hex2",   kind: .props(.full, { AnyView(DotmHex2(props: $0))  })),
        .init(id: "Hex3",   kind: .props(.full, { AnyView(DotmHex3(props: $0))  })),
        .init(id: "Hex4",   kind: .props(.full, { AnyView(DotmHex4(props: $0))  })),
        .init(id: "Hex5",   kind: .props(.full, { AnyView(DotmHex5(props: $0))  })),
        .init(id: "Hex6",   kind: .props(.full, { AnyView(DotmHex6(props: $0))  })),
        .init(id: "Hex7",   kind: .props(.full, { AnyView(DotmHex7(props: $0))  })),
        .init(id: "Hex8",   kind: .props(.full, { AnyView(DotmHex8(props: $0))  })),
        .init(id: "Hex9",   kind: .props(.full, { AnyView(DotmHex9(props: $0))  })),
        .init(id: "Hex10",  kind: .props(.full, { AnyView(DotmHex10(props: $0)) })),

        // MARK: Grid3 (20) — 3×3 grid; pattern unused (the 3×3 base owns its own
        // layout), so we pass `.full` as a no-op to satisfy the `LoaderEntry` shape.
        .init(id: "G3-1",  kind: .props(.full, { AnyView(Dotm3x3_1(props: $0))  })),
        .init(id: "G3-2",  kind: .props(.full, { AnyView(Dotm3x3_2(props: $0))  })),
        .init(id: "G3-3",  kind: .props(.full, { AnyView(Dotm3x3_3(props: $0))  })),
        .init(id: "G3-4",  kind: .props(.full, { AnyView(Dotm3x3_4(props: $0))  })),
        .init(id: "G3-5",  kind: .props(.full, { AnyView(Dotm3x3_5(props: $0))  })),
        .init(id: "G3-6",  kind: .props(.full, { AnyView(Dotm3x3_6(props: $0))  })),
        .init(id: "G3-7",  kind: .props(.full, { AnyView(Dotm3x3_7(props: $0))  })),
        .init(id: "G3-8",  kind: .props(.full, { AnyView(Dotm3x3_8(props: $0))  })),
        .init(id: "G3-9",  kind: .props(.full, { AnyView(Dotm3x3_9(props: $0))  })),
        .init(id: "G3-10", kind: .props(.full, { AnyView(Dotm3x3_10(props: $0)) })),
        .init(id: "G3-11", kind: .props(.full, { AnyView(Dotm3x3_11(props: $0)) })),
        .init(id: "G3-12", kind: .props(.full, { AnyView(Dotm3x3_12(props: $0)) })),
        .init(id: "G3-13", kind: .props(.full, { AnyView(Dotm3x3_13(props: $0)) })),
        .init(id: "G3-14", kind: .props(.full, { AnyView(Dotm3x3_14(props: $0)) })),
        .init(id: "G3-15", kind: .props(.full, { AnyView(Dotm3x3_15(props: $0)) })),
        .init(id: "G3-16", kind: .props(.full, { AnyView(Dotm3x3_16(props: $0)) })),
        .init(id: "G3-18", kind: .props(.full, { AnyView(Dotm3x3_18(props: $0)) })),
        .init(id: "G3-19", kind: .props(.full, { AnyView(Dotm3x3_19(props: $0)) })),
        .init(id: "G3-20", kind: .props(.full, { AnyView(Dotm3x3_20(props: $0)) })),
        .init(id: "G3-21", kind: .props(.full, { AnyView(Dotm3x3_21(props: $0)) })),

        // MARK: Icon (1)
        .init(id: "Icon",      kind: .icon),
    ]

    /// Deterministic pick — same seed always returns the same loader. The seed is
    /// chosen by `MatrixLoadingView` once per identity (`.id(stageKey)`), so a
    /// stage transition recreates the view with a new seed and lands on a
    /// different loader.
    static func pick(seed: Int) -> LoaderEntry {
        let count = all.count
        let normalized = ((seed % count) + count) % count
        return all[normalized]
    }
}
