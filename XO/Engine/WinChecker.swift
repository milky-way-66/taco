import Foundation

enum WinChecker {
    private static let directions = [(1, 0), (0, 1), (1, 1), (1, -1)]

    static func hasWin(at cell: Cell, mark: Mark, cells: [Cell: Mark], winLength: Int) -> Bool {
        winningLine(at: cell, mark: mark, cells: cells, winLength: winLength) != nil
    }

    static func winningLine(
        at cell: Cell,
        mark: Mark,
        cells: [Cell: Mark],
        winLength: Int
    ) -> Set<Cell>? {
        for (dx, dy) in directions {
            var line = [cell]
            line.append(contentsOf: cellsInDirection(from: cell, dx: dx, dy: dy, mark: mark, cells: cells))
            line.append(contentsOf: cellsInDirection(from: cell, dx: -dx, dy: -dy, mark: mark, cells: cells))
            if line.count >= winLength {
                return Set(line)
            }
        }
        return nil
    }

    private static func cellsInDirection(
        from cell: Cell,
        dx: Int,
        dy: Int,
        mark: Mark,
        cells: [Cell: Mark]
    ) -> [Cell] {
        var result: [Cell] = []
        var x = cell.x + dx
        var y = cell.y + dy
        while cells[Cell(x: x, y: y)] == mark {
            result.append(Cell(x: x, y: y))
            x += dx
            y += dy
        }
        return result
    }
}
