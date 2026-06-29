import XCTest
@testable import XO

final class AIPlayerTests: XCTestCase {
    func testTakesWinningMoveOn3x3() {
        var engine = GameEngine(settings: GameSettings(winLength: 3, boardSize: .three, mode: .vsNeighbor))
        _ = try? engine.place(at: Cell(x: 0, y: 0)) // human x
        _ = try? engine.place(at: Cell(x: 1, y: 0)) // ai o
        _ = try? engine.place(at: Cell(x: 2, y: 1)) // human x
        _ = try? engine.place(at: Cell(x: 0, y: 1)) // ai o
        _ = try? engine.place(at: Cell(x: 1, y: 2)) // human x — threat diagonal

        let move = AIPlayer.bestMove(for: engine, difficulty: 5)
        XCTAssertEqual(move, Cell(x: 1, y: 1)) // ai blocks
    }

    func testTakesImmediateWin() {
        let engine = GameEngine(
            settings: GameSettings(winLength: 3, boardSize: .three, mode: .vsNeighbor),
            cells: [
                Cell(x: 0, y: 0): .o,
                Cell(x: 1, y: 0): .o,
                Cell(x: 0, y: 1): .x
            ],
            currentPlayer: .o
        )
        let move = AIPlayer.bestMove(for: engine, difficulty: 5)
        XCTAssertEqual(move, Cell(x: 2, y: 0))
    }

    func testReturnsValidMoveAtLowDifficulty() {
        let engine = GameEngine(settings: GameSettings(winLength: 3, boardSize: .three, mode: .vsNeighbor))
        let move = AIPlayer.bestMove(for: engine, difficulty: 0)
        XCTAssertTrue(engine.canPlay(at: move))
    }
}
