import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

/// One dot of a loader frame, in the field's own coordinate space.
struct DotFieldCell {
    /// Center of the dot, measured from the field's top-leading corner.
    let center: CGPoint
    /// Display opacity of the dot itself (`0` hides it).
    let opacity: Double
    /// Effective glow strength from `DotMatrixBloom.level(...)` (`0` = none).
    let bloom: Double
}

/// The single animated leaf shared by every dot-matrix base.
///
/// Bases describe a frame as a list of cells (`frame(wallClock)`); this view
/// owns the clock and puts the cells on screen.
///
/// ## Why CoreAnimation layers, not SwiftUI views per cell
///
/// Each base used to rebuild 9–49 `Circle`s inside a `TimelineView`, and every
/// glowing cell carried three `.shadow`s plus a `.brightness` filter. Those are
/// offscreen effects: each frame they had to be re-rasterized into fresh
/// RenderBox surfaces. While a host list scrolled, the render server could not
/// hand those surfaces back fast enough, and the app's main thread parked in
/// `RB::SharedSurfaceGroup::add_subsurface → -[CAContext waitForCommitId:]`.
/// Mana's A/B Instruments recordings (2026-10-13) put that wait at ~126–172ms
/// per second of scrolling with this loader on screen, and ~27ms with only it
/// switched off.
///
/// On UIKit platforms the glow is now rasterized ONCE per color/size into a
/// sprite, and every tick only moves and fades existing layers — properties the
/// render server composites with no surface for the app to wait on. The clock
/// is a 30fps `CADisplayLink` owned by the layer view, so a tick does not
/// invalidate the SwiftUI graph either. Elsewhere it falls back to the SwiftUI
/// drawing it replaced.
struct DotField: View {
    let canvasSize: CGSize
    let dotSize: CGFloat
    let color: Color
    let wideBloom: Bool
    let paused: Bool
    let frame: (TimeInterval) -> [DotFieldCell]

    /// Frame-rate ceiling. The loaders animate slow opacity pulses, so 30fps is
    /// not visible, and on a 120Hz display it removes three quarters of the ticks.
    static let frameInterval: TimeInterval = 1.0 / 30.0

    var body: some View {
        #if canImport(UIKit)
        DotFieldLayerHost(
            dotSize: dotSize,
            color: color,
            wideBloom: wideBloom,
            paused: paused,
            frame: frame
        )
        .frame(width: canvasSize.width, height: canvasSize.height)
        #else
        TimelineView(.animation(minimumInterval: Self.frameInterval, paused: paused)) { context in
            let cells = frame(context.date.timeIntervalSinceReferenceDate)
            ZStack(alignment: .topLeading) {
                ForEach(cells.indices, id: \.self) { index in
                    let cell = cells[index]
                    Circle()
                        .fill(color)
                        .frame(width: dotSize, height: dotSize)
                        .opacity(cell.opacity)
                        .dotMatrixBloom(
                            level: cell.bloom,
                            color: color,
                            dotSize: dotSize,
                            wide: wideBloom
                        )
                        .position(cell.center)
                }
            }
            .frame(width: canvasSize.width, height: canvasSize.height)
        }
        #endif
    }
}

#if canImport(UIKit)

private struct DotFieldLayerHost: UIViewRepresentable {
    let dotSize: CGFloat
    let color: Color
    let wideBloom: Bool
    let paused: Bool
    let frame: (TimeInterval) -> [DotFieldCell]

    func makeUIView(context: Context) -> DotFieldLayerView {
        DotFieldLayerView(frame: .zero)
    }

    func updateUIView(_ view: DotFieldLayerView, context: Context) {
        view.configure(
            style: DotFieldStyle(
                color: color.resolve(in: context.environment),
                dotSize: dotSize,
                wideBloom: wideBloom,
                scale: context.environment.displayScale
            ),
            paused: paused,
            frame: frame
        )
    }

    /// The caller pins an exact frame, so take whatever is proposed.
    func sizeThatFits(
        _ proposal: ProposedViewSize,
        uiView: DotFieldLayerView,
        context: Context
    ) -> CGSize? {
        CGSize(width: proposal.width ?? 0, height: proposal.height ?? 0)
    }
}

private struct DotFieldStyle: Hashable {
    let color: Color.Resolved
    let dotSize: CGFloat
    let wideBloom: Bool
    let scale: CGFloat
}

private final class DotFieldLayerView: UIView {
    /// Interleaved per cell: the dot, then its glow sprite above it. The sprite
    /// carries the brightened core, so it must sit over its own dot.
    private var dotLayers: [CALayer] = []
    private var bloomLayers: [CALayer] = []

    private var style: DotFieldStyle?
    private var color: CGColor?
    private var sprite: DotFieldBloomSprite.Image?
    private var paused = true
    private var frameProvider: ((TimeInterval) -> [DotFieldCell])?
    private var displayLink: CADisplayLink?

    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        backgroundColor = .clear
        // Glow bleeds past the grid, exactly like the shadows it replaces.
        clipsToBounds = false
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(
        style: DotFieldStyle,
        paused: Bool,
        frame: @escaping (TimeInterval) -> [DotFieldCell]
    ) {
        frameProvider = frame
        if style != self.style {
            self.style = style
            color = style.color.cgColor
            sprite = DotFieldBloomSprite.image(for: style)
            restyle(dotLayers.indices)
        }
        self.paused = paused
        updateDisplayLink()
        renderFrame()
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        updateDisplayLink()
        if window != nil { renderFrame() }
    }

    /// Runs only while on screen and animating; an off-window loader costs nothing.
    private func updateDisplayLink() {
        let shouldRun = window != nil && !paused
        if shouldRun, displayLink == nil {
            let link = CADisplayLink(
                target: DotFieldDisplayLinkProxy(self),
                selector: #selector(DotFieldDisplayLinkProxy.tick(_:))
            )
            let rate = Float(1 / DotField.frameInterval)
            link.preferredFrameRateRange = CAFrameRateRange(
                minimum: rate / 2,
                maximum: rate,
                preferred: rate
            )
            link.add(to: .main, forMode: .common)
            displayLink = link
        } else if !shouldRun, let link = displayLink {
            link.invalidate()
            displayLink = nil
        }
    }

    func renderFrame() {
        guard let frameProvider, style != nil else { return }
        let cells = frameProvider(Date.timeIntervalSinceReferenceDate)

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        if dotLayers.count < cells.count {
            let added = dotLayers.count..<cells.count
            for _ in added {
                let dot = CALayer()
                let bloom = CALayer()
                layer.addSublayer(dot)
                layer.addSublayer(bloom)
                dotLayers.append(dot)
                bloomLayers.append(bloom)
            }
            restyle(added)
        }
        for (index, cell) in cells.enumerated() {
            let dot = dotLayers[index]
            dot.position = cell.center
            dot.opacity = Float(cell.opacity)
            dot.isHidden = cell.opacity <= 0

            let bloom = bloomLayers[index]
            let glow = cell.opacity * cell.bloom
            bloom.position = cell.center
            bloom.opacity = Float(glow)
            bloom.isHidden = glow <= 0 || sprite == nil
        }
        for index in cells.count..<dotLayers.count where !dotLayers[index].isHidden {
            dotLayers[index].isHidden = true
            bloomLayers[index].isHidden = true
        }
        CATransaction.commit()
    }

    /// Static properties change only with the style, never per tick.
    private func restyle(_ indices: Range<Int>) {
        guard let style else { return }
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        for index in indices {
            let dot = dotLayers[index]
            dot.bounds = CGRect(x: 0, y: 0, width: style.dotSize, height: style.dotSize)
            dot.cornerRadius = style.dotSize / 2
            dot.backgroundColor = color

            let bloom = bloomLayers[index]
            bloom.contents = sprite?.cgImage
            bloom.contentsScale = style.scale
            let side = sprite?.side ?? 0
            bloom.bounds = CGRect(x: 0, y: 0, width: side, height: side)
        }
        CATransaction.commit()
    }
}

/// Breaks the display link's strong reference to its target.
@MainActor
private final class DotFieldDisplayLinkProxy: NSObject {
    private weak var view: DotFieldLayerView?

    init(_ view: DotFieldLayerView) {
        self.view = view
    }

    @objc func tick(_ link: CADisplayLink) {
        guard let view else {
            link.invalidate()
            return
        }
        view.renderFrame()
    }
}

/// The full-strength glow of one dot, rasterized once per style.
///
/// It is the exact SwiftUI bloom (`dotMatrixBloom(level: 1)`) rendered to an
/// image, so the look cannot drift from the fallback path. A cell at level `L`
/// shows it at alpha `opacity × L`: the three shadow bands scale linearly with
/// `L` just as their `color.opacity(k × L)` did, and the brightened core blends
/// over the plain dot, which is what `.brightness(0.16 × L)` amounted to.
@MainActor
private enum DotFieldBloomSprite {
    struct Image {
        let cgImage: CGImage
        let side: CGFloat
    }

    /// Loader colors are seeded per chat turn, so the set is open-ended; keep a
    /// small working set rather than every color ever seen.
    private static let cacheLimit = 32
    private static var cache: [DotFieldStyle: Image] = [:]

    static func image(for style: DotFieldStyle) -> Image? {
        if let cached = cache[style] { return cached }
        guard style.dotSize > 0, style.scale > 0 else { return nil }

        // A SwiftUI shadow's visible falloff ends well inside 3× its radius.
        let reach = ceil(DotMatrixBloom.radii(dotSize: style.dotSize, wide: style.wideBloom).outer * 3)
        let side = style.dotSize + reach * 2
        let color = Color(style.color)
        let content = Circle()
            .fill(color)
            .frame(width: style.dotSize, height: style.dotSize)
            .dotMatrixBloom(level: 1, color: color, dotSize: style.dotSize, wide: style.wideBloom)
            .frame(width: side, height: side)
        let renderer = ImageRenderer(content: content)
        renderer.scale = style.scale
        guard let cgImage = renderer.cgImage else { return nil }

        if cache.count >= cacheLimit { cache.removeAll(keepingCapacity: true) }
        let image = Image(cgImage: cgImage, side: side)
        cache[style] = image
        return image
    }
}

#endif
