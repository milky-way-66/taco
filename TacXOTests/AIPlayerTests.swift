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

        let move = AIPlayer.bestMove(for: engine, hardness: 100)
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
        let move = AIPlayer.bestMove(for: engine, hardness: 100)
        XCTAssertEqual(move, Cell(x: 2, y: 0))
    }

    func testReturnsValidMoveAtLowDifficulty() {
        let engine = GameEngine(settings: GameSettings(winLength: 3, boardSize: .three, mode: .vsNeighbor))
        let move = AIPlayer.bestMove(for: engine, hardness: 0)
        XCTAssertTrue(engine.canPlay(at: move))
    }

    func testBestMoveOnDefaultBoardCompletesQuickly() {
        let engine = GameEngine(settings: GameSettings(winLength: 5, boardSize: .five, mode: .vsNeighbor))
        let start = ContinuousClock.now
        _ = AIPlayer.bestMove(for: engine, hardness: 100)
        let elapsed = start.duration(to: .now)
        XCTAssertLessThan(elapsed, .milliseconds(200))
    }

    func testFirstMoveOn10x10StaysNearCenter() {
        let engine = GameEngine(settings: GameSettings(winLength: 5, boardSize: .ten, mode: .vsNeighbor))
        let start = ContinuousClock.now
        let move = AIPlayer.bestMove(for: engine, hardness: 100)
        let elapsed = start.duration(to: .now)
        XCTAssertTrue((3...6).contains(move.x))
        XCTAssertTrue((3...6).contains(move.y))
        XCTAssertLessThan(elapsed, .milliseconds(200))
    }

    func testBlocksOpponentWinOn10x10() {
        let engine = GameEngine(
            settings: GameSettings(winLength: 5, boardSize: .ten, mode: .vsNeighbor),
            cells: [
                Cell(x: 4, y: 5): .x,
                Cell(x: 5, y: 5): .x,
                Cell(x: 6, y: 5): .x,
                Cell(x: 7, y: 5): .x,
                Cell(x: 5, y: 4): .o
            ],
            currentPlayer: .o
        )
        let move = AIPlayer.bestMove(for: engine, hardness: 100)
        XCTAssertTrue([Cell(x: 3, y: 5), Cell(x: 8, y: 5)].contains(move))
    }

    func testLargeBoardMoveCompletesQuickly() {
        let engine = GameEngine(settings: GameSettings(winLength: 5, boardSize: .ten, mode: .vsNeighbor))
        let start = ContinuousClock.now
        _ = AIPlayer.bestMove(for: engine, hardness: 100)
        let elapsed = start.duration(to: .now)
        XCTAssertLessThan(elapsed, .milliseconds(300))
    }
}
