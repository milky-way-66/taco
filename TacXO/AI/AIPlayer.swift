import Foundation

enum AIPlayer {
    static func bestMove(for engine: GameEngine, difficulty: Int) -> Cell {
        let candidates = candidateCells(for: engine)
        guard !candidates.isEmpty else {
            return Cell(x: 0, y: 0)
        }

        let ranked = rankMoves(candidates, engine: engine)
        let chosen = selectMove(from: ranked, difficulty: difficulty)
        return chosen
    }

    private static func candidateCells(for engine: GameEngine) -> [Cell] {
        let dim = engine.settings.boardSize.dimension
        if dim > 10 {
            return neighborhoodCandidates(engine: engine, dimension: dim)
        }
        return allCellsInBounds(dimension: dim).filter { engine.canPlay(at: $0) }
    }

    private static func allCellsInBounds(dimension: Int) -> [Cell] {
        (0..<dimension).flatMap { y in
            (0..<dimension).map { x in Cell(x: x, y: y) }
        }
    }

    private static func neighborhoodCandidates(engine: GameEngine, dimension: Int) -> [Cell] {
        guard !engine.cells.isEmpty else {
            let center = dimension / 2
            return (-2...2).flatMap { dy in
                (-2...2).map { dx in Cell(x: center + dx, y: center + dy) }
            }.filter { engine.canPlay(at: $0) }
        }

        var set = Set<Cell>()
        for (cell, _) in engine.cells {
            for dx in -2...2 {
                for dy in -2...2 {
                    let candidate = Cell(x: cell.x + dx, y: cell.y + dy)
                    if engine.canPlay(at: candidate) {
                        set.insert(candidate)
                    }
                }
            }
        }
        return Array(set)
    }

    private static func rankMoves(_ moves: [Cell], engine: GameEngine) -> [(Cell, Int)] {
        moves.map { cell in
            (cell, score(move: cell, engine: engine))
        }
        .sorted { $0.1 > $1.1 }
    }

    private static func score(move: Cell, engine: GameEngine) -> Int {
        var copy = engine
        guard (try? copy.place(at: move)) != nil else { return Int.min }
        switch copy.result {
        case .won(let mark) where mark == engine.currentPlayer:
            return 10_000
        default:
            break
        }
        let opponentCopy = GameEngine(
            settings: engine.settings,
            cells: engine.cells,
            currentPlayer: engine.currentPlayer.opponent,
            result: engine.result
        )
        if let block = immediateWinningMove(for: opponentCopy) {
            if block == move { return 5_000 }
        }
        return heuristic(move: move, engine: engine)
    }

    private static func immediateWinningMove(for engine: GameEngine) -> Cell? {
        let moves = candidateCells(for: engine)
        for move in moves {
            var copy = engine
            if let result = try? copy.place(at: move), result == .won(engine.currentPlayer) {
                return move
            }
        }
        return nil
    }

    private static func heuristic(move: Cell, engine: GameEngine) -> Int {
        let dim = engine.settings.boardSize.dimension
        let cx = Double(dim - 1) / 2
        let cy = cx
        let dist = abs(Double(move.x) - cx) + abs(Double(move.y) - cy)
        return Int(10 - dist)
    }

    private static func selectMove(from ranked: [(Cell, Int)], difficulty: Int) -> Cell {
        guard let best = ranked.first?.0 else { return Cell(x: 0, y: 0) }
        let top = ranked.prefix(3).map(\.0)
        switch difficulty {
        case 5: return best
        case 4: return ranked.prefix(2).randomElement()?.0 ?? best
        case 3: return Double.random(in: 0...1) < 0.2 ? (ranked.dropFirst().first?.0 ?? best) : best
        case 2: return Double.random(in: 0...1) < 0.5 ? (ranked.dropFirst().first?.0 ?? best) : best
        case 1: return top.randomElement() ?? best
        default: return top.randomElement() ?? best
        }
    }
}
