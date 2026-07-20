# Matrix

**Animated dot-matrix loading indicators for SwiftUI.**
100+ deterministic, pattern-driven dot loaders that render as tiny animated grids —
a faithful Swift/SwiftUI port of the [`zzzzshawn/matrix`](https://github.com/zzzzshawn/matrix)
loader collection. They power the chat "thinking" states in [Mana](https://mana.am),
an AI-first creation studio for iOS.

<p align="center">
  <img src="https://img.shields.io/badge/Swift-5.9%2B-orange.svg" alt="Swift 5.9+" />
  <img src="https://img.shields.io/badge/platforms-iOS%2018%2B-blue.svg" alt="iOS 18+" />
  <img src="https://img.shields.io/badge/SPM-compatible-brightgreen.svg" alt="SwiftPM compatible" />
</p>

<p align="center">
  <img src="https://github.com/mana-am/matrix-swift/raw/main/Assets/demo.gif" width="280" alt="Matrix dot-matrix loaders demo" />
</p>

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

There are two equivalent ways to use a loader — pick whichever reads better.

**1. Named component** (1:1 with the upstream React library — `<DotmSquare3 />`):

```swift
import SwiftUI
import Matrix

struct LoadingRow: View {
    var body: some View {
        HStack(spacing: 16) {
            DotmSquare3(size: 28)
            DotmHex1(size: 28, color: .blue)
            DotmTriangle5(size: 28, color: .pink, speed: 1.4)
            DotMatrixIcon(size: 28)
        }
    }
}
```

Every loader is its own `View`: `DotmSquare1…23`, `DotmCircular1…20`, `DotmHex1…10`,
`DotmTriangle1…20`, `Dotm3x3_1…21`, the Fun set (`DotmFunHeart`, `DotmFunArrow`,
`DotmFunSparkle`, …), and `DotMatrixIcon`. Each takes the same ergonomic init:
`(size:color:speed:dotSize:muted:bloom:halo:)`.

**2. Shape id** (one view, parameterized — handy for pickers / random / storing a choice):

```swift
MatrixLoader(.square(3), size: 28)
MatrixLoader(.hex(1), size: 28, color: .blue)
MatrixLoader(.triangle(5), size: 28, color: .pink, speed: 1.4)
MatrixLoader(.fun(.heart), size: 28, color: .red)
MatrixLoader(.icon, size: 28)
```

Index ranges: `square` 1…23 · `circular` 1…20 · `hex` 1…10 · `grid3` 1…16 & 18…21
· `triangle` 1…20 · `fun(.heart / .arrow / .sparkle / …)` · `icon`. Every id is
enumerable via `MatrixLoaderID.all` — build a picker or choose one at random.

> **Coming from [`zzzzshawn/matrix`](https://github.com/zzzzshawn/matrix)?** The named
> components match the upstream exports 1:1 (`DotmSquare3`, `DotmHex1`, `Dotm3x3_7`,
> `DotmTriangle5`, `DotMatrixIcon`), so docs and examples carry over. The **Fun**
> family (`DotmFun…` / `MatrixLoader(.fun(…))`) is an addition in this port and has no
> upstream counterpart.

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

`MatrixLoadingView` draws from a pool of 72. Triangle and 3×3 loaders remain
available for explicit selection and in `MatrixLoaderGallery`, but are excluded
from the random runtime pool.

## How it works

- **No assets, no dependencies.** Pure SwiftUI — every loader is drawn from
  animated `Circle`s driven by a `TimelineView`.
- **Pattern-driven grids.** Each loader animates a mask over a small grid
  (5×5 / hex / 3×3 / 7×7 triangle) via a per-cell opacity resolver, ported 1:1
  from the upstream CSS keyframes and JS math.
- **Reduce Motion aware.** Animations pause and fall back to a static,
  accessibility-correct pose automatically.

## Public API

- **Named components** — `DotmSquare1…23`, `DotmCircular1…20`, `DotmHex1…10`,
  `DotmTriangle1…20`, `Dotm3x3_1…21`, `DotmFun…`, `DotMatrixIcon`. Each is a `View`
  with an ergonomic `(size:color:speed:dotSize:muted:bloom:halo:)` init. This mirrors
  the upstream React library's per-component API.
- `MatrixLoader` — render a loader by `MatrixLoaderID` (shape + index), sized and
  colored to taste. Equivalent to the named components; nicer when the choice is data.
- `MatrixLoadingView` — deterministic runtime loader with a semantic
  `MatrixLoadingIntensity`: `.standard` preserves the restrained default, while
  `.vivid` enables denser dots and layered bloom for high-contrast status surfaces.
- `MatrixLoaderID` / `FunLoader` — the loader catalog; `MatrixLoaderID.all`
  enumerates every loader.
- `MatrixLoaderGallery` — the interactive showcase (Liquid-Glass chip bar per family).

## Credits & License

Ported from [`zzzzshawn/matrix`](https://github.com/zzzzshawn/matrix), published
as a standalone Swift package **with the author's kind permission**. Please keep
the attribution and the link back to the upstream project. See [LICENSE](LICENSE).

Maintained by [Mana](https://mana.am) — an AI-first creation studio for iOS.
