import XCTest
@testable import TacXO

final class AIPlayerTests: XCTestCase {
    func testBlocksOpponentWinOn3x3() {
        let engine = GameEngine(
            settings: GameSettings(winLength: 3, boardSize: .three, mode: .vsNeighbor),
            cells: [
                Cell(x: 0, y: 0): .x,
                Cell(x: 1, y: 0): .x,
                Cell(x: 0, y: 1): .o
            ],
            currentPlayer: .o
        )

        let move = AIPlayer.bestMove(for: engine, difficulty: 5)
        XCTAssertEqual(move, Cell(x: 2, y: 0))
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
