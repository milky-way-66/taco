import Foundation
import Observation

@Observable
final class GameController {
    var settings: GameSettings
    private(set) var engine: GameEngine
    private(set) var difficulty = AdaptiveDifficulty()
    var lossQuote: String?
    var showLossOverlay = false

    /// Human is always X; Neighbor is O in vs Neighbor mode
    var isHumanTurn: Bool {
        settings.mode == .twoPlayer || engine.currentPlayer == .x
    }

    init(settings: GameSettings = .load()) {
        self.settings = settings
        self.engine = GameEngine(settings: settings)
    }

    func applySettings(_ newSettings: GameSettings) {
        settings = newSettings
        settings.save()
        newGame()
    }

    func newGame() {
        engine = GameEngine(settings: settings)
        lossQuote = nil
        showLossOverlay = false
    }

    func tap(cell: Cell) {
        guard engine.result == .ongoing else { return }
        guard isHumanTurn else { return }
        guard engine.canPlay(at: cell) else { return }

        performMove(at: cell)

        if settings.mode == .vsNeighbor, engine.result == .ongoing {
            let aiMove = AIPlayer.bestMove(for: engine, difficulty: difficulty.level)
            performMove(at: aiMove)
        }
    }

    private func performMove(at cell: Cell) {
        guard let result = try? engine.place(at: cell) else { return }
        SoundManager.shared.playPlace()

        switch result {
        case .won(let mark):
            handleGameEnd(winner: mark)
        case .draw:
            break
        case .ongoing:
            break
        }
    }

    private func handleGameEnd(winner: Mark) {
        if settings.mode == .vsNeighbor {
            if winner == .x {
                difficulty.recordWin()
                SoundManager.shared.playWin()
            } else {
                difficulty.recordLoss()
                lossQuote = NeighborQuotes.random()
                showLossOverlay = true
                SoundManager.shared.playNeighborLoss()
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                    self?.showLossOverlay = false
                }
            }
        }
    }
}
