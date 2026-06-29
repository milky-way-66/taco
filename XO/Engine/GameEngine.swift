import Foundation

enum GameResult: Equatable {
    case ongoing
    case won(Mark)
    case draw
}

enum GameError: Error {
    case outOfBounds
    case cellOccupied
    case gameOver
}

struct GameEngine {
    let settings: GameSettings
    private(set) var cells: [Cell: Mark] = [:]
    private(set) var currentPlayer: Mark = .x
    private(set) var result: GameResult = .ongoing

    init(settings: GameSettings) {
        self.settings = settings
    }

    internal init(settings: GameSettings, cells: [Cell: Mark], currentPlayer: Mark, result: GameResult = .ongoing) {
        self.settings = settings
        self.cells = cells
        self.currentPlayer = currentPlayer
        self.result = result
    }

    func canPlay(at cell: Cell) -> Bool {
        guard result == .ongoing else { return false }
        guard isInBounds(cell) else { return false }
        return cells[cell] == nil
    }

    mutating func place(at cell: Cell) throws -> GameResult {
        guard result == .ongoing else { throw GameError.gameOver }
        guard isInBounds(cell) else { throw GameError.outOfBounds }
        guard cells[cell] == nil else { throw GameError.cellOccupied }

        cells[cell] = currentPlayer

        if WinChecker.hasWin(at: cell, mark: currentPlayer, cells: cells, winLength: settings.winLength) {
            result = .won(currentPlayer)
            return result
        }

        if isDraw() {
            result = .draw
            return result
        }

        currentPlayer = currentPlayer.opponent
        return .ongoing
    }

    mutating func reset() {
        cells = [:]
        currentPlayer = .x
        result = .ongoing
    }

    private func isInBounds(_ cell: Cell) -> Bool {
        guard let dim = settings.boardSize.dimension else { return true }
        return (0..<dim).contains(cell.x) && (0..<dim).contains(cell.y)
    }

    private func isDraw() -> Bool {
        guard settings.boardSize.dimension != nil else { return false }
        guard let dim = settings.boardSize.dimension else { return false }
        return cells.count >= dim * dim
    }
}
