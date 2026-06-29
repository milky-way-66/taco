import Foundation
import Observation

@Observable
final class GameController {
    var settings: GameSettings
    private(set) var engine: GameEngine
    private(set) var difficulty = AdaptiveDifficulty()
    private(set) var isAIThinking = false
    private(set) var isWinCelebrating = false
    var quoteOverlay: QuoteOverlay?
    private(set) var gameID = UUID()

    /// Human is always X; Neighbor is O in vs Neighbor mode
    var isHumanTurn: Bool {
        settings.mode == .twoPlayer || engine.currentPlayer == .x
    }

    var canAcceptInput: Bool {
        engine.result == .ongoing && isHumanTurn && !isAIThinking
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
        isAIThinking = false
        isWinCelebrating = false
        engine = GameEngine(settings: settings)
        quoteOverlay = nil
        gameID = UUID()
    }

    func dismissQuoteOverlay() {
        quoteOverlay = nil
    }

    func tap(cell: Cell) {
        guard canAcceptInput else { return }
        guard engine.canPlay(at: cell) else { return }

        performMove(at: cell)

        guard settings.mode == .vsNeighbor, engine.result == .ongoing else { return }

        isAIThinking = true
        let snapshot = engine
        let level = difficulty.level

        Task { @MainActor in
            defer { isAIThinking = false }

            try? await Task.sleep(for: .milliseconds(220))

            guard engine.result == .ongoing else { return }

            let aiMove = await Task.detached(priority: .userInitiated) {
                AIPlayer.bestMove(for: snapshot, difficulty: level)
            }.value

            guard engine.result == .ongoing else { return }
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
        isWinCelebrating = true
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(1500))
            isWinCelebrating = false
        }

        guard settings.mode == .vsNeighbor else {
            SoundManager.shared.playWin()
            return
        }

        if winner == .x {
            difficulty.recordWin()
            SoundManager.shared.playWin()
            presentQuote(NeighborWinQuotes.random(language: settings.language), kind: .victory)
        } else {
            difficulty.recordLoss()
            SoundManager.shared.playNeighborLoss()
            presentQuote(NeighborQuotes.random(language: settings.language), kind: .defeat)
        }
    }

    private func presentQuote(_ quote: NeighborQuote, kind: QuoteOverlayKind) {
        quoteOverlay = QuoteOverlay(quote: quote, kind: kind)
    }
}

struct QuoteOverlay: Equatable {
    let quote: NeighborQuote
    let kind: QuoteOverlayKind
}

enum QuoteOverlayKind: Equatable {
    case victory
    case defeat
}
