import Foundation

/// Identifies which "stage" of the chat flow a loading slot represents.
///
/// Drives the speed multiplier passed into `DotMatrixCommonProps.speed`. Each chat
/// call site (PreparationStageView / ToolCallActivityView / SubagentDisclosureView)
/// derives its own `ChatLoadingPhase` from local model state — see
/// `MatrixLoadingView` for the wiring.
public enum ChatLoadingPhase: Hashable {
    case waiting        // pre-first-byte: sandbox boot, file download
    case thinking       // model thinking before tokens start
    case streaming      // text actively streaming (reserved for future use)
    case toolRunning    // tool executing local work
    case toolWaiting    // tool blocked on slow network I/O

    /// Global speed boost applied on top of every per-phase multiplier.
    /// One knob to tune the overall pacing of every chat loader.
    static let globalSpeedBoost: Double = 1.1

    var speedMultiplier: Double {
        let base: Double
        switch self {
        case .waiting:      base = 0.75
        case .thinking:     base = 1.00
        case .streaming:    base = 1.20
        case .toolRunning:  base = 1.10
        case .toolWaiting:  base = 0.85
        }
        return base * Self.globalSpeedBoost
    }
}
