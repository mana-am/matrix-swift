# Contributing

## Setup

```bash
swift build
swift test
```

## Layout

- `Sources/Matrix/Core` — grid geometry, patterns, opacity remap, bloom, math.
- `Sources/Matrix/Base` — grid base views (5×5, hex, 3×3, 7×7 triangle) + factories.
- `Sources/Matrix/Keyframes` — CSS `@keyframes` ports (time → opacity functions).
- `Sources/Matrix/Clocks` — stepped / continuous cycle clocks.
- `Sources/Matrix/Loaders` — the individual loaders, one file each, grouped by family.
- `Sources/Matrix/Runtime` — `MatrixLoadingView`, the pool, color + phase helpers.
- `Sources/Matrix/Gallery` — `MatrixLoaderGallery` showcase.

## Adding a loader

Add a file under the matching `Loaders/<Family>/` folder mirroring the upstream
`dotm-*` component, register it in `Runtime/MatrixLoadingPool.swift` (unless it
should stay out of the chat pool), and add a tile to `MatrixLoaderGallery`.

Ports must match the upstream math/keyframes exactly — don't improvise timing or
easing. Reuse the shared helpers in `Keyframes/` and `Clocks/`.

## Before sending a PR

```bash
swift build
swift test
```

## License

This is a derivative port of `zzzzshawn/matrix` and carries the upstream custom
proprietary license. See the root `LICENSE`.
