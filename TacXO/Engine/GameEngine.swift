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
    private(set) var winningCells: Set<Cell> = []
    private(set) var lastPlayedCell: Cell?

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
        lastPlayedCell = cell

        if let line = WinChecker.winningLine(
            at: cell,
            mark: currentPlayer,
            cells: cells,
            winLength: settings.winLength
        ) {
            winningCells = line
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
        winningCells = []
        lastPlayedCell = nil
    }

    private func isInBounds(_ cell: Cell) -> Bool {
        let dim = settings.boardSize.dimension
        return (0..<dim).contains(cell.x) && (0..<dim).contains(cell.y)
    }

    private func isDraw() -> Bool {
        let dim = settings.boardSize.dimension
        return cells.count >= dim * dim
    }
}
