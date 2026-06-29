import Foundation

enum AIPlayer {
    static func bestMove(for engine: GameEngine, difficulty: Int) -> Cell {
        let candidates = candidateCells(for: engine)
        guard !candidates.isEmpty else {
            return Cell(x: 0, y: 0)
        }

        if let win = immediateWinningMove(for: engine) {
            return win
        }

        let opponentEngine = GameEngine(
            settings: engine.settings,
            cells: engine.cells,
            currentPlayer: engine.currentPlayer.opponent,
            result: engine.result
        )
        if difficulty >= 2, let block = immediateWinningMove(for: opponentEngine) {
            return block
        }

        let depth = searchDepth(for: engine, difficulty: difficulty)
        let ranked: [(Cell, Int)]
        if depth > 0 {
            ranked = rankWithMinimax(candidates, engine: engine, depth: depth)
        } else {
            ranked = rankMoves(candidates, engine: engine)
        }

        return selectMove(from: ranked, difficulty: difficulty)
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

    private static func searchDepth(for engine: GameEngine, difficulty: Int) -> Int {
        let dim = engine.settings.boardSize.dimension
        let emptyCells = dim * dim - engine.cells.count

        let baseDepth: Int
        switch dim {
        case ...3:
            baseDepth = emptyCells
        case ...5:
            baseDepth = min(6, emptyCells)
        case ...10:
            baseDepth = min(4, emptyCells)
        default:
            return 0
        }

        switch difficulty {
        case 5: return baseDepth
        case 4: return max(1, baseDepth - 1)
        case 3: return max(1, baseDepth - 2)
        case 2: return max(1, min(2, baseDepth - 3))
        default: return 0
        }
    }

    private static func rankWithMinimax(_ moves: [Cell], engine: GameEngine, depth: Int) -> [(Cell, Int)] {
        let ordered = moves.sorted {
            heuristic(move: $0, engine: engine) > heuristic(move: $1, engine: engine)
        }
        let aiMark = engine.currentPlayer

        return ordered.map { move in
            var copy = engine
            _ = try? copy.place(at: move)
            let score = minimax(
                engine: copy,
                depth: depth - 1,
                alpha: Int.min,
                beta: Int.max,
                aiMark: aiMark,
                rootDepth: depth
            )
            return (move, score)
        }
        .sorted { $0.1 > $1.1 }
    }

    private static func minimax(
        engine: GameEngine,
        depth: Int,
        alpha: Int,
        beta: Int,
        aiMark: Mark,
        rootDepth: Int
    ) -> Int {
        switch engine.result {
        case .won(let mark):
            let plyBonus = rootDepth - depth
            return mark == aiMark ? 1_000_000 - plyBonus : -1_000_000 + plyBonus
        case .draw:
            return 0
        case .ongoing:
            break
        }

        if depth == 0 {
            return evaluatePosition(engine: engine, aiMark: aiMark)
        }

        let candidates = orderedCandidates(for: engine)
        let isMaximizing = engine.currentPlayer == aiMark

        if isMaximizing {
            var best = Int.min
            var alpha = alpha
            for move in candidates {
                var copy = engine
                guard (try? copy.place(at: move)) != nil else { continue }
                best = max(best, minimax(
                    engine: copy,
                    depth: depth - 1,
                    alpha: alpha,
                    beta: beta,
                    aiMark: aiMark,
                    rootDepth: rootDepth
                ))
                alpha = max(alpha, best)
                if beta <= alpha { break }
            }
            return best
        }

        var best = Int.max
        var beta = beta
        for move in candidates {
            var copy = engine
            guard (try? copy.place(at: move)) != nil else { continue }
            best = min(best, minimax(
                engine: copy,
                depth: depth - 1,
                alpha: alpha,
                beta: beta,
                aiMark: aiMark,
                rootDepth: rootDepth
            ))
            beta = min(beta, best)
            if beta <= alpha { break }
        }
        return best
    }

    private static func orderedCandidates(for engine: GameEngine) -> [Cell] {
        candidateCells(for: engine).sorted {
            heuristic(move: $0, engine: engine) > heuristic(move: $1, engine: engine)
        }
    }

    private static func evaluatePosition(engine: GameEngine, aiMark: Mark) -> Int {
        let winLength = engine.settings.winLength
        let dimension = engine.settings.boardSize.dimension
        var score = 0

        for (cell, mark) in engine.cells {
            let threat = lineThreatScore(
                at: cell,
                mark: mark,
                cells: engine.cells,
                winLength: winLength,
                dimension: dimension
            )
            score += mark == aiMark ? threat : -threat
        }

        return score
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
        if let block = immediateWinningMove(for: opponentCopy), block == move {
            return 5_000
        }
        return heuristic(move: move, engine: engine)
    }

    private static func immediateWinningMove(for engine: GameEngine) -> Cell? {
        let moves = candidateCells(for: engine)
        for move in moves {
            var copy = engine
            if let result = try? copy.place(at: move), case .won(let mark) = result, mark == engine.currentPlayer {
                return move
            }
        }
        return nil
    }

    private static func heuristic(move: Cell, engine: GameEngine) -> Int {
        var copy = engine
        guard (try? copy.place(at: move)) != nil else { return Int.min }

        let player = engine.currentPlayer
        let opponent = player.opponent
        let winLength = engine.settings.winLength
        let dimension = engine.settings.boardSize.dimension

        var score = lineThreatScore(
            at: move,
            mark: player,
            cells: copy.cells,
            winLength: winLength,
            dimension: dimension
        )
        score += lineThreatScore(
            at: move,
            mark: opponent,
            cells: copy.cells,
            winLength: winLength,
            dimension: dimension
        ) * 9 / 10

        let center = Double(dimension - 1) / 2
        let distance = abs(Double(move.x) - center) + abs(Double(move.y) - center)
        score += Int(12 - distance)

        return score
    }

    private static func lineThreatScore(
        at cell: Cell,
        mark: Mark,
        cells: [Cell: Mark],
        winLength: Int,
        dimension: Int
    ) -> Int {
        guard cells[cell] == mark else { return 0 }

        var total = 0
        for (dx, dy) in [(1, 0), (0, 1), (1, 1), (1, -1)] {
            let segment = analyzeLine(
                at: cell,
                dx: dx,
                dy: dy,
                mark: mark,
                cells: cells,
                dimension: dimension
            )
            total += evaluateSegment(count: segment.count, openEnds: segment.openEnds, winLength: winLength)
        }
        return total
    }

    private static func analyzeLine(
        at cell: Cell,
        dx: Int,
        dy: Int,
        mark: Mark,
        cells: [Cell: Mark],
        dimension: Int
    ) -> (count: Int, openEnds: Int) {
        let forward = extendLine(from: cell, dx: dx, dy: dy, mark: mark, cells: cells)
        let backward = extendLine(from: cell, dx: -dx, dy: -dy, mark: mark, cells: cells)
        let count = 1 + forward + backward

        let forwardOpen = isOpenEndAfterRun(
            from: cell,
            dx: dx,
            dy: dy,
            steps: forward,
            cells: cells,
            dimension: dimension
        )
        let backwardOpen = isOpenEndAfterRun(
            from: cell,
            dx: -dx,
            dy: -dy,
            steps: backward,
            cells: cells,
            dimension: dimension
        )

        return (count, (forwardOpen ? 1 : 0) + (backwardOpen ? 1 : 0))
    }

    private static func extendLine(
        from cell: Cell,
        dx: Int,
        dy: Int,
        mark: Mark,
        cells: [Cell: Mark]
    ) -> Int {
        var length = 0
        var x = cell.x + dx
        var y = cell.y + dy
        while cells[Cell(x: x, y: y)] == mark {
            length += 1
            x += dx
            y += dy
        }
        return length
    }

    private static func isOpenEndAfterRun(
        from cell: Cell,
        dx: Int,
        dy: Int,
        steps: Int,
        cells: [Cell: Mark],
        dimension: Int
    ) -> Bool {
        let x = cell.x + dx * (steps + 1)
        let y = cell.y + dy * (steps + 1)
        guard (0..<dimension).contains(x), (0..<dimension).contains(y) else { return false }
        return cells[Cell(x: x, y: y)] == nil
    }

    private static func evaluateSegment(count: Int, openEnds: Int, winLength: Int) -> Int {
        guard openEnds > 0, count > 0 else { return 0 }
        if count >= winLength { return 100_000 }

        switch (count, openEnds) {
        case (winLength - 1, 2): return 12_000
        case (winLength - 1, 1): return 2_500
        case (winLength - 2, 2): return 900
        case (winLength - 2, 1): return 180
        case (winLength - 3, 2): return 120
        case (winLength - 3, 1): return 30
        default:
            return count * count * openEnds
        }
    }

    private static func selectMove(from ranked: [(Cell, Int)], difficulty: Int) -> Cell {
        guard let best = ranked.first?.0 else { return Cell(x: 0, y: 0) }
        let top = ranked.prefix(3).map(\.0)

        switch difficulty {
        case 5, 4:
            return best
        case 3:
            return Double.random(in: 0...1) < 0.1 ? (ranked.dropFirst().first?.0 ?? best) : best
        case 2:
            return Double.random(in: 0...1) < 0.25 ? (ranked.dropFirst().first?.0 ?? best) : best
        case 1:
            return ranked.prefix(2).randomElement()?.0 ?? best
        default:
            return top.randomElement() ?? best
        }
    }
}
