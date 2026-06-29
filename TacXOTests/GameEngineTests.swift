import XCTest
@testable import TacXO

final class GameEngineTests: XCTestCase {
    func testXStartsFirst() {
        let engine = GameEngine(settings: GameSettings(winLength: 3, boardSize: .three, mode: .twoPlayer))
        XCTAssertEqual(engine.currentPlayer, .x)
    }

    func testValidMoveAlternatesTurn() throws {
        var engine = GameEngine(settings: GameSettings(winLength: 3, boardSize: .three, mode: .twoPlayer))
        let result = try engine.place(at: Cell(x: 0, y: 0))
        XCTAssertEqual(result, .ongoing)
        XCTAssertEqual(engine.currentPlayer, .o)
        XCTAssertEqual(engine.cells[Cell(x: 0, y: 0)], .x)
    }

    func testRejectsOccupiedCell() {
        var engine = GameEngine(settings: GameSettings(winLength: 3, boardSize: .three, mode: .twoPlayer))
        _ = try? engine.place(at: Cell(x: 1, y: 1))
        XCTAssertThrowsError(try engine.place(at: Cell(x: 1, y: 1)))
    }

    func testRejectsOutOfBoundsOnFixedBoard() {
        var engine = GameEngine(settings: GameSettings(winLength: 3, boardSize: .three, mode: .twoPlayer))
        XCTAssertThrowsError(try engine.place(at: Cell(x: 3, y: 0)))
    }

    func testDetectsWin() throws {
        var engine = GameEngine(settings: GameSettings(winLength: 3, boardSize: .three, mode: .twoPlayer))
        _ = try engine.place(at: Cell(x: 0, y: 0)) // x
        _ = try engine.place(at: Cell(x: 1, y: 0)) // o
        _ = try engine.place(at: Cell(x: 0, y: 1)) // x
        _ = try engine.place(at: Cell(x: 1, y: 1)) // o
        let result = try engine.place(at: Cell(x: 0, y: 2)) // x wins column
        XCTAssertEqual(result, .won(.x))
    }

    func testDetectsDrawOn3x3() throws {
        var engine = GameEngine(settings: GameSettings(winLength: 3, boardSize: .three, mode: .twoPlayer))
        let moves: [Cell] = [
            Cell(x: 0, y: 0), Cell(x: 0, y: 1),
            Cell(x: 1, y: 1), Cell(x: 0, y: 2),
            Cell(x: 2, y: 1), Cell(x: 1, y: 0),
            Cell(x: 1, y: 2), Cell(x: 2, y: 2),
            Cell(x: 2, y: 0)
        ]
        var last: GameResult = .ongoing
        for move in moves {
            last = try engine.place(at: move)
        }
        XCTAssertEqual(last, .draw)
    }

    func testResetClearsBoard() throws {
        var engine = GameEngine(settings: GameSettings(winLength: 3, boardSize: .three, mode: .twoPlayer))
        _ = try engine.place(at: Cell(x: 0, y: 0))
        engine.reset()
        XCTAssertTrue(engine.cells.isEmpty)
        XCTAssertEqual(engine.currentPlayer, .x)
    }

    func testRejectsOutOfBoundsOn25x25() {
        var engine = GameEngine(settings: GameSettings(winLength: 5, boardSize: .twentyFive, mode: .twoPlayer))
        XCTAssertThrowsError(try engine.place(at: Cell(x: 25, y: 0)))
    }

    func testTwentyFiveBoardAcceptsValidCell() throws {
        var engine = GameEngine(settings: GameSettings(winLength: 5, boardSize: .twentyFive, mode: .twoPlayer))
        let result = try engine.place(at: Cell(x: 12, y: 12))
        XCTAssertEqual(result, .ongoing)
    }
}
