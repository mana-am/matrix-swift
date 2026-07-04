import Matrix
import SwiftUI

@main
struct ExampleApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ExampleScreen()
            }
        }
    }
}

private struct ExampleScreen: View {
    private let phaseSamples: [(label: String, phase: ChatLoadingPhase)] = [
        ("waiting", .waiting),
        ("thinking", .thinking),
        ("streaming", .streaming),
        ("toolRunning", .toolRunning),
        ("toolWaiting", .toolWaiting),
    ]

    var body: some View {
        List {
            Section("Drop-in loader") {
                // `MatrixLoadingView` picks a loader + coordinated color
                // deterministically from `stageKey` — the same key always lands
                // on the same loader across view rebuilds.
                HStack(spacing: 28) {
                    ForEach(["alpha", "beta", "gamma", "delta"], id: \.self) { key in
                        MatrixLoadingView(
                            size: 28, phase: .thinking, stageKey: key, useRandomColor: true)
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 8)
            }

            Section("Phases — speed reflects the chat stage") {
                ForEach(phaseSamples, id: \.label) { sample in
                    HStack(spacing: 14) {
                        MatrixLoadingView(
                            size: 24, phase: sample.phase, stageKey: sample.label,
                            useRandomColor: true)
                        Text(sample.label)
                            .font(.callout.monospaced())
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Section {
                NavigationLink {
                    MatrixLoaderGallery()
                } label: {
                    Label("Browse all loaders", systemImage: "square.grid.3x3.fill")
                }
            } footer: {
                Text("Square · Circular · Hex · Fun · 3×3 · Triangle · Icon")
            }
        }
        .navigationTitle("Matrix")
    }
}
