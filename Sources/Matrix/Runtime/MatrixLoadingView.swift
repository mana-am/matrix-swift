import SwiftUI

// MARK: - Loader turn key (environment)

/// Optional "turn id" injected by a parent view. When set, the seed for every
/// nested `MatrixLoadingView` is derived from
/// `hash(turnKey, stageKey)` — i.e. the per-call-site `stageKey` becomes a
/// **dimension tag** that segments loaders within one turn.
///
/// Within one turn:
///   - All call sites passing the *same* `stageKey` → same loader+color
///     (e.g. all preparation stages with `stageKey: "prep"`, all tool
///      capsules with `stageKey: "tools"`).
///   - Call sites passing *different* `stageKey` → different loader+color
///     (prep loader ≠ tools loader ≠ subagent loader).
/// Across turns: different turn id → entirely different mapping per dimension.
///
/// `AssistantMessageBubble` injects `message.id` here so one bubble = one turn.
private struct LoaderTurnKeyEnvironmentKey: EnvironmentKey {
    static let defaultValue: String? = nil
}

extension EnvironmentValues {
    var loaderTurnKey: String? {
        get { self[LoaderTurnKeyEnvironmentKey.self] }
        set { self[LoaderTurnKeyEnvironmentKey.self] = newValue }
    }
}

extension View {
    /// Scope every nested `MatrixLoadingView` to one chat turn. Inside this
    /// scope, the per-call-site `stageKey` is interpreted as a *dimension tag*
    /// (e.g. `"prep"`, `"tools"`, `"subagent"`) and combined with the turn key
    /// to derive the seed: same dimension tag → same loader, different
    /// dimension tag → different loader, next turn → new loader per dimension.
    /// Pass `nil` to fall back to plain per-call-site `stageKey` behavior
    /// (used by previews / debug gallery).
    public func matrixLoaderTurnKey(_ key: String?) -> some View {
        environment(\.loaderTurnKey, key)
    }
}

/// Drop-in replacement for the legacy `Pixel(...)` loading view. Picks a loader
/// from `MatrixLoadingPool` and a coordinated random color from the same seed,
/// then runs the loader at a speed that reflects the current chat phase.
///
/// `stageKey` is the identity used to decide when to reshuffle. Pass any
/// `Hashable` value that changes when the loading "stage" changes — e.g. the
/// `PreparationStage` enum case, a tool call's id, or a composite key combining
/// a subagent id with its `hasRunningTools` flag. When `stageKey` changes,
/// `.id(stageKey)` recreates the inner view and a new loader+color combination
/// renders.
///
/// **Turn-level override**: when a parent sets `.matrixLoaderTurnKey(turnId)`,
/// the env value supersedes `stageKey` for seed derivation. Within one turn,
/// every loader (preparation / tools / subagent) lands on the same loader+color;
/// stage transitions and tool switches no longer reshuffle. The next turn
/// supplies a different turn id, which produces a different loader.
///
/// The seed is derived **deterministically** rather than from `Int.random()`.
/// This guarantees that a given key always lands on the same loader within a
/// single app session — important because LazyVStack / LazyHStack rebuild
/// views as cells scroll out of viewport and back; with `Int.random()` the
/// loader would visibly "swap" each time the user scrolls past a tool call.
/// Hash-derived seeds are stable across rebuilds.
public struct MatrixLoadingView<Key: Hashable>: View {
    let size: CGFloat
    let phase: ChatLoadingPhase
    let stageKey: Key
    let useRandomColor: Bool
    var fallbackColor: Color

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.loaderTurnKey) private var turnKeyOverride

    public init(
        size: CGFloat,
        phase: ChatLoadingPhase,
        stageKey: Key,
        useRandomColor: Bool,
        fallbackColor: Color = .osFallbackColorDefault
    ) {
        self.size = size
        self.phase = phase
        self.stageKey = stageKey
        self.useRandomColor = useRandomColor
        self.fallbackColor = fallbackColor
    }

    public var body: some View {
        // When a parent supplied a turn id, derive the seed from
        // `hash(turn, stageKey)`. Inside that scope, `stageKey` is a stable
        // dimension tag — so every loader sharing the same tag within the
        // turn picks the same loader+color, while different tags get
        // different ones. Outside the scope (previews, gallery) we fall
        // back to a `stageKey`-only hash so each call site gets its own
        // loader, the way a standalone preview expects.
        let seed: Int = {
            if let turn = turnKeyOverride {
                var hasher = Hasher()
                turn.hash(into: &hasher)
                stageKey.hash(into: &hasher)
                let h = hasher.finalize()
                return h == .min ? 0 : abs(h)
            }
            return Self.seed(from: stageKey)
        }()

        // ZStack + .id + .transition gives us a real insert/remove cycle on
        // stageKey change instead of the bare `.id()` swap. The asymmetric
        // transition reads as "scatter then regroup": the old loader collapses
        // inward and fades out (dots scatter), the new loader pops in slightly
        // oversized then springs to rest (dots regroup). animation(value:) is
        // bound to seed so transitions only fire on real loader swaps.
        ZStack {
            InternalView(
                size: size,
                phase: phase,
                useRandomColor: useRandomColor,
                fallbackColor: fallbackColor,
                seed: seed
            )
            .id(seed)
            .transition(reduceMotion ? .opacity : .matrixDotRegroup)
        }
        .animation(
            reduceMotion ? .easeInOut(duration: 0.15)
                         : .spring(response: 0.34, dampingFraction: 0.78),
            value: seed
        )
    }

    private static func seed(from key: Key) -> Int {
        var hasher = Hasher()
        key.hash(into: &hasher)
        let h = hasher.finalize()
        // Map Int.min safely (abs(.min) traps).
        return h == .min ? 0 : abs(h)
    }
}

// MARK: - Scatter / Regroup transition

/// Visual modifier driving the `.matrixDotRegroup` transition: scale + opacity
/// + a faint blur. Blur is the part that sells the "dots dispersing" feel —
/// without it scale-only reads as a generic pop. Kept small (≤4pt) to stay
/// cheap on the GPU and avoid jelly.
private struct MatrixDotRegroupModifier: ViewModifier {
    let scale: CGFloat
    let opacity: Double
    let blur: CGFloat

    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .opacity(opacity)
            .blur(radius: blur)
    }
}

private extension AnyTransition {
    /// Insert: dots arrive slightly oversized & blurry, then spring to rest.
    /// Remove: dots collapse inward and blur out — reads as "scatter".
    static var matrixDotRegroup: AnyTransition {
        .asymmetric(
            insertion: .modifier(
                active: MatrixDotRegroupModifier(scale: 1.18, opacity: 0, blur: 3),
                identity: MatrixDotRegroupModifier(scale: 1.0, opacity: 1, blur: 0)
            ),
            removal: .modifier(
                active: MatrixDotRegroupModifier(scale: 0.55, opacity: 0, blur: 4),
                identity: MatrixDotRegroupModifier(scale: 1.0, opacity: 1, blur: 0)
            )
        )
    }
}

private struct InternalView: View {
    let size: CGFloat
    let phase: ChatLoadingPhase
    let useRandomColor: Bool
    let fallbackColor: Color
    let seed: Int

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        // Reduce Motion: DotMatrixBase already pauses TimelineView. Static
        // dots + low-saturation pastel are essentially invisible, so force
        // the fallback color (theme-adaptive `Color(.secondaryLabel)`) for
        // accessibility-correct contrast.
        let effectiveUseRandom = reduceMotion ? false : useRandomColor

        let entry = MatrixLoadingPool.pick(seed: seed)
        let color = MatrixLoadingColor.resolve(
            seed: seed,
            useRandom: effectiveUseRandom,
            fallback: fallbackColor,
            colorScheme: colorScheme
        )
        let speed = phase.speedMultiplier
        // 5×5 grid sized to mirror the gallery's chatProps5 sizing rule:
        // dotSize = max(2, floor(size/6)); cellPadding = 1; matrixSpan = dot*5+4.
        let dot = max(2, floor(size / 6))
        let span = dot * 5 + 4

        // Subtle halo gives every active dot a faint glow. Reduce Motion
        // skips it (the static dots don't need haloing, and the wide falloff
        // would be visually noisy without animation to mask it). Halo is
        // intentionally tuned low — at chat scale (dot ≤ 4pt) the wider
        // falloff is what reads, not the inner ring; values above ~0.2 start
        // bleeding into adjacent text.
        let haloLevel: Double = reduceMotion ? 0 : 0.15

        switch entry.kind {
        case .props(let pattern, let build):
            let props = DotMatrixCommonProps(
                size: span,
                dotSize: dot,
                color: color,
                speed: speed,
                pattern: pattern,
                cellPadding: 1,
                showInactiveDots: true,
                inactiveDotOpacity: 0.06,
                halo: haloLevel
            )
            build(props)
        case .icon:
            DotMatrixIcon(
                size: span,
                dotSize: dot,
                color: color,
                speed: speed,
                cellPadding: 1,
                showInactiveDots: true,
                halo: haloLevel
            )
        }
    }
}

extension Color {
    public static var osFallbackColorDefault: Color {
        #if os(iOS)
        Color(uiColor: .secondaryLabel)
        #elseif os(macOS)
        .secondary
        #endif
    }
}
