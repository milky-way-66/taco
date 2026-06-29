import XCTest
@testable import TacXO

final class WinCheckerTests: XCTestCase {
    func testHorizontalWin() {
        var cells: [Cell: Mark] = [:]
        for x in 0..<5 { cells[Cell(x: x, y: 0)] = .x }
        XCTAssertTrue(WinChecker.hasWin(at: Cell(x: 4, y: 0), mark: .x, cells: cells, winLength: 5))
    }

    func testVerticalWin() {
        var cells: [Cell: Mark] = [:]
        for y in 0..<4 { cells[Cell(x: 2, y: y)] = .o }
        cells[Cell(x: 2, y: 4)] = .o
        XCTAssertTrue(WinChecker.hasWin(at: Cell(x: 2, y: 4), mark: .o, cells: cells, winLength: 5))
    }

    func testDiagonalWin() {
        var cells: [Cell: Mark] = [:]
        for i in 0..<3 {
            cells[Cell(x: i, y: i)] = .x
        }
        XCTAssertTrue(WinChecker.hasWin(at: Cell(x: 2, y: 2), mark: .x, cells: cells, winLength: 3))
    }

    func testWinningLine() {
        var cells: [Cell: Mark] = [:]
        for x in 0..<5 { cells[Cell(x: x, y: 0)] = .x }
        let line = WinChecker.winningLine(at: Cell(x: 4, y: 0), mark: .x, cells: cells, winLength: 5)
        XCTAssertEqual(line?.count, 5)
    }

    func testNoWinYet() {
        var cells: [Cell: Mark] = [:]
        cells[Cell(x: 0, y: 0)] = .x
        cells[Cell(x: 1, y: 0)] = .x
        XCTAssertFalse(WinChecker.hasWin(at: Cell(x: 1, y: 0), mark: .x, cells: cells, winLength: 3))
    }

    func testWinThroughGap() {
        var cells: [Cell: Mark] = [:]
        cells[Cell(x: 0, y: 0)] = .x
        cells[Cell(x: 1, y: 0)] = .x
        cells[Cell(x: 3, y: 0)] = .x
        XCTAssertFalse(WinChecker.hasWin(at: Cell(x: 3, y: 0), mark: .x, cells: cells, winLength: 3))
    }
}
