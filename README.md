# Matrix

**Animated dot-matrix loading indicators for SwiftUI.**
100+ deterministic, pattern-driven dot loaders that render as tiny animated grids —
a faithful Swift/SwiftUI port of the [`zzzzshawn/matrix`](https://github.com/zzzzshawn/matrix)
loader collection.

<p align="center">
  <img src="https://img.shields.io/badge/Swift-5.9%2B-orange.svg" alt="Swift 5.9+" />
  <img src="https://img.shields.io/badge/platforms-iOS%2018%2B-blue.svg" alt="iOS 18+" />
  <img src="https://img.shields.io/badge/SPM-compatible-brightgreen.svg" alt="SwiftPM compatible" />
</p>

<!-- Replace with a screen recording of the loaders in action -->
<!-- <p align="center"><img src=".github/demo.gif" alt="Matrix dot loaders" width="480" /></p> -->

## When to use

- You want a compact, lively loading indicator — chat "thinking", tool activity,
  inline spinners — that reads as a hand-tuned dot grid, not a stock spinner.
- You want **deterministic** selection: the same key always lands on the same
  loader, so loaders don't visibly reshuffle as SwiftUI rebuilds views on scroll.
- You want a big, varied catalog (Square, Circular, Hex, Fun, 3×3, Triangle, Icon)
  behind one drop-in view.

## Installation

Add the package in Xcode (**File ▸ Add Package Dependencies…**) or in your
`Package.swift`:

```swift
.package(url: "https://github.com/mana-am/matrix-swift", from: "1.0.0")
```

Then add `Matrix` to your target's dependencies and `import Matrix`.

## Quick start

```swift
import SwiftUI
import Matrix

struct ThinkingRow: View {
    var body: some View {
        // Picks a loader + coordinated color deterministically from `stageKey`,
        // and runs it at a speed that reflects the current phase.
        MatrixLoadingView(
            size: 22,
            phase: .streaming,
            stageKey: "tools",
            useRandomColor: true
        )
    }
}
```

Scope every nested loader to one "turn" so all loaders in a unit of work share
the same pick, and the next turn gets a fresh one:

```swift
messageBody
    .matrixLoaderTurnKey(message.id)
```

## Example

A runnable Swift Playgrounds app lives in [`Example.swiftpm`](Example.swiftpm) —
open it in Swift Playgrounds or Xcode and press **Run** to try every loader live,
with theme / speed / color / reduce-motion controls.

## Browse every loader

The package ships a self-contained, interactive gallery:

```swift
import Matrix

NavigationLink("Loaders") { MatrixLoaderGallery() }
```

## Loaders

| Family    | Count | Notes |
| --------- | ----- | ----- |
| Square    | 23    | 5×5 grid |
| Circular  | 20    | 5×5, circular mask |
| Hex       | 10    | hex lattice (19 cells) |
| Fun       | 18    | silhouettes + motion (heart, arrow, sparkle, snake, confetti…) |
| 3×3       | 20    | compact 3×3 grid |
| Triangle  | 20    | 7×7 triangle silhouette |
| Icon      | 1     | brand icon loader |

`MatrixLoadingView` draws from a pool of 92 (every family except Triangle). Any
loader is browsable in `MatrixLoaderGallery`.

## How it works

- **Deterministic pick.** `MatrixLoadingView` hashes `stageKey` (or a parent
  `matrixLoaderTurnKey`) into a stable seed, so a given identity always resolves
  to the same loader + color across view rebuilds — no visible reshuffling.
- **Pattern-driven grids.** Each loader animates a mask over a small grid
  (5×5 / hex / 3×3 / 7×7 triangle) via a per-cell opacity resolver, ported 1:1
  from the upstream CSS keyframes and JS math.
- **Reduce Motion aware.** Animations pause and fall back to a static,
  accessibility-correct pose automatically.

## Public API

- `MatrixLoadingView` — the drop-in, auto-selecting loader.
- `ChatLoadingPhase` — phase → speed mapping (`waiting` / `thinking` /
  `streaming` / `toolRunning` / `toolWaiting`).
- `View.matrixLoaderTurnKey(_:)` — scope a subtree to one loader "turn".
- `MatrixLoaderGallery` — the interactive showcase.

## Credits & License

Ported from [`zzzzshawn/matrix`](https://github.com/zzzzshawn/matrix), published
as a standalone Swift package **with the author's kind permission**. Please keep
the attribution and the link back to the upstream project. See [LICENSE](LICENSE).
