import Foundation

enum WinChecker {
    private static let directions = [(1, 0), (0, 1), (1, 1), (1, -1)]

    static func hasWin(at cell: Cell, mark: Mark, cells: [Cell: Mark], winLength: Int) -> Bool {
        for (dx, dy) in directions {
            let count = 1
                + countDirection(from: cell, dx: dx, dy: dy, mark: mark, cells: cells)
                + countDirection(from: cell, dx: -dx, dy: -dy, mark: mark, cells: cells)
            if count >= winLength { return true }
        }
        return false
    }

    private static func countDirection(
        from cell: Cell,
        dx: Int,
        dy: Int,
        mark: Mark,
        cells: [Cell: Mark]
    ) -> Int {
        var count = 0
        var x = cell.x + dx
        var y = cell.y + dy
        while cells[Cell(x: x, y: y)] == mark {
            count += 1
            x += dx
            y += dy
        }
        return count
    }
}
