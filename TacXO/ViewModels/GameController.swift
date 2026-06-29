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
    private(set) var neighborComment: NeighborComment?
    private(set) var gameID = UUID()

    private var commentDismissTask: Task<Void, Never>?

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
        clearNeighborComment()
        gameID = UUID()
    }

    func dismissQuoteOverlay() {
        quoteOverlay = nil
    }

    func tap(cell: Cell) {
        guard canAcceptInput else { return }
        guard engine.canPlay(at: cell) else { return }

        let beforeMove = engine
        performMove(at: cell)

        guard settings.mode == .vsNeighbor, engine.result == .ongoing else { return }

        maybeComment(on: cell, before: beforeMove)

        isAIThinking = true
        let snapshot = engine
        let hardness = difficulty.hardnessPercent

        Task { @MainActor in
            defer { isAIThinking = false }

            let aiMove = await Task.detached(priority: .high) {
                AIPlayer.bestMove(for: snapshot, hardness: hardness)
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

    private func maybeComment(on move: Cell, before engine: GameEngine) {
        let assessment = AIPlayer.assessHumanMove(
            move,
            before: engine,
            hardness: difficulty.hardnessPercent
        )
        guard let text = NeighborMoveComments.comment(
            for: assessment,
            move: move,
            moveNumber: engine.cells.count,
            language: settings.language
        ) else { return }

        neighborComment = NeighborComment(
            text: text,
            mood: assessment.quality.commentMood
        )

        commentDismissTask?.cancel()
        commentDismissTask = Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(4500))
            guard !Task.isCancelled else { return }
            neighborComment = nil
        }
    }

    private func clearNeighborComment() {
        commentDismissTask?.cancel()
        commentDismissTask = nil
        neighborComment = nil
    }

    private func handleGameEnd(winner: Mark) {
        clearNeighborComment()
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
            let delta = difficulty.recordWin()
            SoundManager.shared.playWin()
            presentQuote(
                NeighborWinQuotes.random(language: settings.language),
                kind: .victory,
                hardnessPercent: difficulty.hardnessPercent,
                hardnessDelta: delta,
                winStreak: difficulty.winStreak
            )
        } else {
            let delta = difficulty.recordLoss()
            SoundManager.shared.playNeighborLoss()
            presentQuote(
                NeighborQuotes.random(language: settings.language),
                kind: .defeat,
                hardnessPercent: difficulty.hardnessPercent,
                hardnessDelta: delta,
                winStreak: difficulty.winStreak
            )
        }
    }

    private func presentQuote(
        _ quote: NeighborQuote,
        kind: QuoteOverlayKind,
        hardnessPercent: Int,
        hardnessDelta: Int,
        winStreak: Int
    ) {
        quoteOverlay = QuoteOverlay(
            quote: quote,
            kind: kind,
            hardnessPercent: hardnessPercent,
            hardnessDelta: hardnessDelta,
            winStreak: winStreak
        )
    }
}

struct QuoteOverlay: Equatable {
    let quote: NeighborQuote
    let kind: QuoteOverlayKind
    let hardnessPercent: Int
    let hardnessDelta: Int
    let winStreak: Int
}

enum QuoteOverlayKind: Equatable {
    case victory
    case defeat
}
