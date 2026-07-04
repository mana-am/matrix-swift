import SwiftUI

/// Showcases every dot-matrix loader family (Square / Circular / Hex / Fun / 3×3
/// / Triangle / Icon) ported from `zzzzshawn/matrix`. The toolbar exposes color
/// scheme, speed, and color; the `Chat` tab previews loaders at chat scale.
public struct MatrixLoaderGallery: View {
    public init() {}


    enum ThemeMode: String, CaseIterable, Identifiable {
        case system, light, dark
        var id: String { rawValue }
        var label: String {
            switch self {
            case .system: return "System"
            case .light: return "Light"
            case .dark: return "Dark"
            }
        }
        var scheme: ColorScheme? {
            switch self {
            case .system: return nil
            case .light: return .light
            case .dark: return .dark
            }
        }
    }

    enum Category: String, CaseIterable, Identifiable {
        // `.all` removed — rendering 64 loaders with active TimelineViews crashes SwiftUI
        // on real device (memory + CoreAnimation pipeline overload). Use the category tabs.
        case chat, fun, square, circular, hex, grid3, triangle, icon
        var id: String { rawValue }
        var label: String {
            switch self {
            case .chat: return "Chat"
            case .fun: return "Fun (18)"
            case .square: return "Square (23)"
            case .circular: return "Circular (20)"
            case .hex: return "Hex (10)"
            case .grid3: return "3×3 (20)"
            case .triangle: return "Triangle (20)"
            case .icon: return "Icon"
            }
        }
        var symbol: String {
            switch self {
            case .chat: return "message.fill"
            case .fun: return "sparkles"
            case .square: return "square.grid.2x2.fill"
            case .circular: return "circle.grid.2x2.fill"
            case .hex: return "hexagon.fill"
            case .grid3: return "square.grid.3x3.fill"
            case .triangle: return "triangle.fill"
            case .icon: return "app.dashed"
            }
        }
        var tabTitle: String {
            switch self {
            case .chat: return "Chat"
            case .fun: return "Fun"
            case .square: return "Square"
            case .circular: return "Circle"
            case .hex: return "Hex"
            case .grid3: return "3×3"
            case .triangle: return "Tri"
            case .icon: return "Icon"
            }
        }
    }

    private enum Layout {
        static let cellSize: CGFloat = 56
        static let columns = 4
        static let labelFont: Font = .caption2
    }

    @State private var theme: ThemeMode = .system
    @State private var speed: Double = 1.0
    // Only the selected category's grid is mounted at a time (see `content`), so a
    // rich default is fine — Square lazily renders its 23 loaders via LazyVGrid.
    @State private var category: Category = .square
    @State private var colorChoice: ColorChoice = .primary

    enum ColorChoice: String, CaseIterable, Identifiable {
        case primary, pink, cyan, orange
        var id: String { rawValue }
        var color: Color {
            switch self {
            case .primary: return .primary
            case .pink: return .pink
            case .cyan: return .cyan
            case .orange: return .orange
            }
        }
        var label: String {
            switch self {
            case .primary: return "Primary"
            case .pink: return "Pink"
            case .cyan: return "Cyan"
            case .orange: return "Orange"
            }
        }
    }

    public var body: some View {
        VStack(spacing: 0) {
            toolbar
                .padding(.top, 12)
                .padding(.bottom, 8)

            ScrollView {
                content
                    .padding(.horizontal)
                    .padding(.top, 4)
                    .padding(.bottom, 24)
            }

            categoryTabBar
        }
        .navigationTitle(category.label)
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(theme.scheme)
    }

    /// Bottom tab bar that switches loader families. A custom bar (not `TabView`)
    /// so only the *selected* family's grid is ever mounted — mounting every
    /// family's animated loaders at once overwhelms the CoreAnimation pipeline.
    @ViewBuilder
    private var categoryTabBar: some View {
        HStack(spacing: 0) {
            ForEach(Category.allCases) { c in
                Button {
                    withAnimation(.easeOut(duration: 0.15)) { category = c }
                } label: {
                    VStack(spacing: 3) {
                        Image(systemName: c.symbol)
                            .font(.system(size: 16))
                        Text(c.tabTitle)
                            .font(.system(size: 10, weight: .medium))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 8)
                    .foregroundStyle(category == c ? Color.accentColor : Color.secondary)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.bottom, 2)
        .background(.bar)
        .overlay(alignment: .top) { Divider() }
    }

    @ViewBuilder
    private var toolbar: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Theme").font(.caption).foregroundStyle(.secondary)
                Picker("Theme", selection: $theme) {
                    ForEach(ThemeMode.allCases) { t in
                        Text(t.label).tag(t)
                    }
                }
                .pickerStyle(.segmented)
            }

            HStack {
                Text("Speed").font(.caption).foregroundStyle(.secondary)
                Slider(value: $speed, in: 0.25...2.5)
                Text(String(format: "%.2fx", speed))
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
                    .frame(width: 56, alignment: .trailing)
            }

            HStack(spacing: 10) {
                Text("Color").font(.caption).foregroundStyle(.secondary)
                ForEach(ColorChoice.allCases) { c in
                    Button {
                        colorChoice = c
                    } label: {
                        Circle()
                            .fill(c.color == .primary ? Color.primary : c.color)
                            .frame(width: 22, height: 22)
                            .overlay(
                                Circle()
                                    .strokeBorder(
                                        Color.primary.opacity(colorChoice == c ? 0.7 : 0),
                                        lineWidth: 2
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                }
                Spacer()
            }
        }
        .padding(.horizontal)
    }

    @ViewBuilder
    private var content: some View {
        switch category {
        case .chat: chatGrid
        case .fun: funGrid
        case .square: squareGrid
        case .circular: circularGrid
        case .hex: hexGrid
        case .grid3: grid3Grid
        case .triangle: triangleGrid
        case .icon: iconGrid
        }
    }

    private var gridColumns: [GridItem] {
        Array(
            repeating: GridItem(.flexible(), spacing: 12),
            count: Layout.columns
        )
    }


    private var squareGrid: some View {
        LazyVGrid(columns: gridColumns, spacing: 16) {
            tile("S1") { DotmSquare1(props: makeProps()) }
            tile("S2") { DotmSquare2(props: makeProps()) }
            tile("S3") { DotmSquare3(props: makeProps()) }
            tile("S4") { DotmSquare4(props: makeProps()) }
            tile("S5") { DotmSquare5(props: makeProps()) }
            tile("S6") { DotmSquare6(props: makeProps()) }
            tile("S7") { DotmSquare7(props: makeProps()) }
            tile("S8") { DotmSquare8(props: makeProps()) }
            tile("S9") { DotmSquare9(props: makeProps()) }
            tile("S10") { DotmSquare10(props: makeProps()) }
            tile("S11") { DotmSquare11(props: makeProps()) }
            tile("S12") { DotmSquare12(props: makeProps()) }
            tile("S13") { DotmSquare13(props: makeProps()) }
            tile("S14") { DotmSquare14(props: makeProps()) }
            tile("S15") { DotmSquare15(props: makeProps()) }
            tile("S16") { DotmSquare16(props: makeProps()) }
            tile("S17") { DotmSquare17(props: makeProps()) }
            tile("S18") { DotmSquare18(props: makeProps()) }
            tile("S19") { DotmSquare19(props: makeProps()) }
            tile("S20") { DotmSquare20(props: makeProps()) }
            tile("S21") { DotmSquare21(props: makeProps()) }
            tile("S22") { DotmSquare22(props: makeProps()) }
            tile("S23") { DotmSquare23(props: makeProps()) }
        }
    }

    private var hexGrid: some View {
        LazyVGrid(columns: gridColumns, spacing: 16) {
            tile("Hex 1") { DotmHex1(props: makeProps()) }
            tile("Hex 2") { DotmHex2(props: makeProps()) }
            tile("Hex 3") { DotmHex3(props: makeProps()) }
            tile("Hex 4") { DotmHex4(props: makeProps()) }
            tile("Hex 5") { DotmHex5(props: makeProps()) }
            tile("Hex 6") { DotmHex6(props: makeProps()) }
            tile("Hex 7") { DotmHex7(props: makeProps()) }
            tile("Hex 8") { DotmHex8(props: makeProps()) }
            tile("Hex 9") { DotmHex9(props: makeProps()) }
            tile("Hex 10") { DotmHex10(props: makeProps()) }
        }
    }

    private var grid3Grid: some View {
        LazyVGrid(columns: gridColumns, spacing: 16) {
            tile("3×3 1") { Dotm3x3_1(props: makeProps()) }
            tile("3×3 2") { Dotm3x3_2(props: makeProps()) }
            tile("3×3 3") { Dotm3x3_3(props: makeProps()) }
            tile("3×3 4") { Dotm3x3_4(props: makeProps()) }
            tile("3×3 5") { Dotm3x3_5(props: makeProps()) }
            tile("3×3 6") { Dotm3x3_6(props: makeProps()) }
            tile("3×3 7") { Dotm3x3_7(props: makeProps()) }
            tile("3×3 8") { Dotm3x3_8(props: makeProps()) }
            tile("3×3 9") { Dotm3x3_9(props: makeProps()) }
            tile("3×3 10") { Dotm3x3_10(props: makeProps()) }
            tile("3×3 11") { Dotm3x3_11(props: makeProps()) }
            tile("3×3 12") { Dotm3x3_12(props: makeProps()) }
            tile("3×3 13") { Dotm3x3_13(props: makeProps()) }
            tile("3×3 14") { Dotm3x3_14(props: makeProps()) }
            tile("3×3 15") { Dotm3x3_15(props: makeProps()) }
            tile("3×3 16") { Dotm3x3_16(props: makeProps()) }
            tile("3×3 18") { Dotm3x3_18(props: makeProps()) }
            tile("3×3 19") { Dotm3x3_19(props: makeProps()) }
            tile("3×3 20") { Dotm3x3_20(props: makeProps()) }
            tile("3×3 21") { Dotm3x3_21(props: makeProps()) }
        }
    }

    /// Triangle family is translated for parity with upstream but **not** used in
    /// Mana chat (not in `MatrixLoadingPool`) — this gallery tab is its only home.
    private var triangleGrid: some View {
        LazyVGrid(columns: gridColumns, spacing: 16) {
            tile("Tri 1") { DotmTriangle1(props: makeProps()) }
            tile("Tri 2") { DotmTriangle2(props: makeProps()) }
            tile("Tri 3") { DotmTriangle3(props: makeProps()) }
            tile("Tri 4") { DotmTriangle4(props: makeProps()) }
            tile("Tri 5") { DotmTriangle5(props: makeProps()) }
            tile("Tri 6") { DotmTriangle6(props: makeProps()) }
            tile("Tri 7") { DotmTriangle7(props: makeProps()) }
            tile("Tri 8") { DotmTriangle8(props: makeProps()) }
            tile("Tri 9") { DotmTriangle9(props: makeProps()) }
            tile("Tri 10") { DotmTriangle10(props: makeProps()) }
            tile("Tri 11") { DotmTriangle11(props: makeProps()) }
            tile("Tri 12") { DotmTriangle12(props: makeProps()) }
            tile("Tri 13") { DotmTriangle13(props: makeProps()) }
            tile("Tri 14") { DotmTriangle14(props: makeProps()) }
            tile("Tri 15") { DotmTriangle15(props: makeProps()) }
            tile("Tri 16") { DotmTriangle16(props: makeProps()) }
            tile("Tri 17") { DotmTriangle17(props: makeProps()) }
            tile("Tri 18") { DotmTriangle18(props: makeProps()) }
            tile("Tri 19") { DotmTriangle19(props: makeProps()) }
            tile("Tri 20") { DotmTriangle20(props: makeProps()) }
        }
    }

    private var circularGrid: some View {
        LazyVGrid(columns: gridColumns, spacing: 16) {
            tile("C1") { DotmCircular1(props: makeProps()) }
            tile("C2") { DotmCircular2(props: makeProps()) }
            tile("C3") { DotmCircular3(props: makeProps()) }
            tile("C4") { DotmCircular4(props: makeProps()) }
            tile("C5") { DotmCircular5(props: makeProps()) }
            tile("C6") { DotmCircular6(props: makeProps()) }
            tile("C7") { DotmCircular7(props: makeProps()) }
            tile("C8") { DotmCircular8(props: makeProps()) }
            tile("C9") { DotmCircular9(props: makeProps()) }
            tile("C10") { DotmCircular10(props: makeProps()) }
            tile("C11") { DotmCircular11(props: makeProps()) }
            tile("C12") { DotmCircular12(props: makeProps()) }
            tile("C13") { DotmCircular13(props: makeProps()) }
            tile("C14") { DotmCircular14(props: makeProps()) }
            tile("C15") { DotmCircular15(props: makeProps()) }
            tile("C16") { DotmCircular16(props: makeProps()) }
            tile("C17") { DotmCircular17(props: makeProps()) }
            tile("C18") { DotmCircular18(props: makeProps()) }
            tile("C19") { DotmCircular19(props: makeProps()) }
            tile("C20") { DotmCircular20(props: makeProps()) }
        }
    }

    private var funGrid: some View {
        // All loaders share 19×19pt span (identical to Square/Circular/Icon). Shape comes
        // from `props.pattern`. Order: shapes (5+6) first, then full-grid motion-only (7).
        LazyVGrid(columns: gridColumns, spacing: 16) {
            // Shapes
            tile("Heart") { DotmFunHeart(props: makeFunProps(.heart)) }
            tile("Mana M") { DotmFunManaM(props: makeFunProps(.manaM)) }
            tile("Arrow") { DotmFunArrow(props: makeFunProps(.arrowRight)) }
            tile("Sparkle") { DotmFunSparkle(props: makeFunProps(.sparkle)) }
            tile("Eye") { DotmFunEye(props: makeFunProps(.eye)) }
            tile("Lightning") { DotmFunLightning(props: makeFunProps(.lightning)) }
            tile("Flower") { DotmFunFlower(props: makeFunProps(.flower)) }
            tile("Wave") { DotmFunWaveShape(props: makeFunProps(.wave)) }
            tile("Hexagon") { DotmFunHexagon(props: makeFunProps(.hexagon)) }
            // Motion-only (full grid)
            tile("Ink") { DotmFunInkBleed(props: makeFunProps(.full)) }
            tile("Tokens") { DotmFunTokenFall(props: makeFunProps(.full)) }
            tile("Breathing") { DotmFunBreathing(props: makeFunProps(.full)) }
            tile("Wave-bend") { DotmFunWaveBend(props: makeFunProps(.full)) }
            tile("Snake") { DotmFunSnake(props: makeFunProps(.full)) }
            tile("Confetti") { DotmFunConfetti(props: makeFunProps(.full)) }
            tile("Shimmer") { DotmFunShimmer(props: makeFunProps(.full)) }
            tile("Pulse") { DotmFunPulseRing(props: makeFunProps(.full)) }
            tile("Cursor") { DotmFunCursor(props: makeFunProps(.full)) }
        }
    }

    private func makeFunProps(_ pattern: MatrixPattern) -> DotMatrixCommonProps {
        DotMatrixCommonProps(
            size: 22,
            dotSize: 3,
            color: colorChoice.color,
            speed: speed,
            pattern: pattern,
            cellPadding: 1,
            showInactiveDots: true,
            inactiveDotOpacity: 0.06
        )
    }

    private var iconGrid: some View {
        // dotSize 3 + cellPadding 1 → 19pt span (matches Square/Circular).
        LazyVGrid(columns: gridColumns, spacing: 16) {
            tile("Idle") {
                DotMatrixIcon(
                    size: 22, dotSize: 3, color: colorChoice.color,
                    speed: speed, animated: false, cellPadding: 1,
                    showInactiveDots: true
                )
            }
            tile("Ripple") {
                DotMatrixIcon(
                    size: 22, dotSize: 3, color: colorChoice.color,
                    speed: speed, animated: true, cellPadding: 1,
                    showInactiveDots: true
                )
            }
            tile("Muted") {
                DotMatrixIcon(
                    size: 22, dotSize: 3, color: colorChoice.color,
                    speed: speed, animated: true, muted: true, cellPadding: 1,
                    showInactiveDots: true
                )
            }
        }
    }

    /// Side-by-side: the production `MatrixLoadingView` (left of each row, at chat's real
    /// sizes) vs. the individual loaders that feed its random pool. Useful for sanity-
    /// checking the production widget alongside specific candidates.
    private var chatGrid: some View {
        VStack(spacing: 18) {
            chatRow(
                title: "Preparation (size 20, .thinking)",
                production: AnyView(
                    MatrixLoadingView(
                        size: 20,
                        phase: .thinking,
                        stageKey: "preview-prep",
                        useRandomColor: true
                    )
                ),
                size: 20
            )
            chatRow(
                title: "Tool / Subagent (size 17, .toolRunning)",
                production: AnyView(
                    MatrixLoadingView(
                        size: 17,
                        phase: .toolRunning,
                        stageKey: "preview-tool",
                        useRandomColor: false
                    )
                ),
                size: 17
            )
        }
        .padding(.horizontal, 4)
    }

    @ViewBuilder
    private func chatRow(title: String, production: AnyView, size: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.caption).foregroundStyle(.secondary)
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 14) {
                    chatCandidate("Prod", size: size) { production }
                    chatCandidate("Icon", size: size) {
                        DotMatrixIcon(
                            size: size, dotSize: max(2, floor(size / 6)),
                            color: colorChoice.color, speed: speed
                        )
                    }
                    chatCandidate("S2", size: size) {
                        DotmSquare2(props: chatProps5(size: size))
                    }
                    chatCandidate("S3", size: size) {
                        DotmSquare3(props: chatProps5(size: size))
                    }
                    chatCandidate("S5", size: size) {
                        DotmSquare5(props: chatProps5(size: size))
                    }
                    chatCandidate("S6", size: size) {
                        DotmSquare6(props: chatProps5(size: size))
                    }
                    chatCandidate("S11", size: size) {
                        DotmSquare11(props: chatProps5(size: size))
                    }
                    chatCandidate("C1", size: size) {
                        DotmCircular1(props: chatProps5(size: size))
                    }
                    chatCandidate("C2", size: size) {
                        DotmCircular2(props: chatProps5(size: size))
                    }
                    chatCandidate("C19", size: size) {
                        DotmCircular19(props: chatProps5(size: size))
                    }
                    chatCandidate("Heart", size: size) {
                        DotmFunHeart(props: chatProps5Pattern(size: size, pattern: .heart))
                    }
                    chatCandidate("M", size: size) {
                        DotmFunManaM(props: chatProps5Pattern(size: size, pattern: .manaM))
                    }
                    chatCandidate("Arrow", size: size) {
                        DotmFunArrow(props: chatProps5Pattern(size: size, pattern: .arrowRight))
                    }
                    chatCandidate("Ink", size: size) {
                        DotmFunInkBleed(props: chatProps5(size: size))
                    }
                    chatCandidate("Tokens", size: size) {
                        DotmFunTokenFall(props: chatProps5(size: size))
                    }
                    chatCandidate("Sparkle", size: size) {
                        DotmFunSparkle(props: chatProps5Pattern(size: size, pattern: .sparkle))
                    }
                    chatCandidate("Eye", size: size) {
                        DotmFunEye(props: chatProps5Pattern(size: size, pattern: .eye))
                    }
                    chatCandidate("Lightning", size: size) {
                        DotmFunLightning(
                            props: chatProps5Pattern(size: size, pattern: .lightning))
                    }
                    chatCandidate("Flower", size: size) {
                        DotmFunFlower(props: chatProps5Pattern(size: size, pattern: .flower))
                    }
                    chatCandidate("Wave", size: size) {
                        DotmFunWaveShape(props: chatProps5Pattern(size: size, pattern: .wave))
                    }
                    chatCandidate("Hex", size: size) {
                        DotmFunHexagon(props: chatProps5Pattern(size: size, pattern: .hexagon))
                    }
                    chatCandidate("Breath", size: size) {
                        DotmFunBreathing(props: chatProps5(size: size))
                    }
                    chatCandidate("Bend", size: size) {
                        DotmFunWaveBend(props: chatProps5(size: size))
                    }
                    chatCandidate("Snake", size: size) {
                        DotmFunSnake(props: chatProps5(size: size))
                    }
                    chatCandidate("Confetti", size: size) {
                        DotmFunConfetti(props: chatProps5(size: size))
                    }
                    chatCandidate("Shimmer", size: size) {
                        DotmFunShimmer(props: chatProps5(size: size))
                    }
                    chatCandidate("Pulse", size: size) {
                        DotmFunPulseRing(props: chatProps5(size: size))
                    }
                    chatCandidate("Cursor", size: size) {
                        DotmFunCursor(props: chatProps5(size: size))
                    }
                }
                .padding(.horizontal, 2)
            }
        }
    }

    @ViewBuilder
    private func chatCandidate<V: View>(
        _ label: String, size: CGFloat, @ViewBuilder content: () -> V
    ) -> some View {
        VStack(spacing: 6) {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color(.tertiarySystemBackground))
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
                content()
            }
            .frame(width: size + 12, height: size + 12)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }

    /// 5×5 props sized for chat: dotSize ≈ size / 6, cellPadding 1, default `.full` pattern.
    private func chatProps5(size: CGFloat) -> DotMatrixCommonProps {
        chatProps5Pattern(size: size, pattern: .full)
    }

    private func chatProps5Pattern(size: CGFloat, pattern: MatrixPattern) -> DotMatrixCommonProps {
        let dot = max(2, floor(size / 6))
        return DotMatrixCommonProps(
            size: dot * 5 + 4,
            dotSize: dot,
            color: colorChoice.color == .primary ? Color(.secondaryLabel) : colorChoice.color,
            speed: speed,
            pattern: pattern,
            cellPadding: 1,
            showInactiveDots: true,
            inactiveDotOpacity: 0.06
        )
    }


    @ViewBuilder
    private func tile<V: View>(_ label: String, @ViewBuilder content: () -> V) -> some View {
        VStack(spacing: 6) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(.tertiarySystemBackground))
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
                content()
            }
            .frame(width: Layout.cellSize, height: Layout.cellSize)
            Text(label)
                .font(Layout.labelFont)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private func makeProps() -> DotMatrixCommonProps {
        // 5×5: dotSize 3 + cellPadding 1 → span 3*5 + 1*4 = 19pt (≈ chat Pixel footprint).
        DotMatrixCommonProps(
            size: 22,
            dotSize: 3,
            color: colorChoice.color,
            speed: speed,
            pattern: .full,
            cellPadding: 1,
            showInactiveDots: true,
            inactiveDotOpacity: 0.06
        )
    }

}

#Preview {
    NavigationStack {
        MatrixLoaderGallery()
    }
}
