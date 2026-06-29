import Foundation

enum HumanMoveQuality: Equatable {
    case excellent
    case good
    case mediocre
    case poor
    case blunder
}

enum AIPlayer {
    static func bestMove(for engine: GameEngine, hardness: Int) -> Cell {
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
        if aiLevel(from: hardness) >= 1, let block = immediateWinningMove(for: opponentEngine) {
            return block
        }

        let depth = searchDepth(for: engine, hardness: hardness)
        let ranked: [(Cell, Int)]
        if depth > 0, usesMinimaxSearch(for: engine) {
            ranked = rankWithMinimax(candidates, engine: engine, depth: depth)
        } else {
            ranked = rankMoves(candidates, engine: engine)
        }

        return selectMove(from: ranked, hardness: hardness)
    }

    private static func usesMinimaxSearch(for engine: GameEngine) -> Bool {
        engine.settings.boardSize.dimension <= 10
    }

    static func evaluateHumanMove(_ move: Cell, before engine: GameEngine, hardness: Int) -> HumanMoveQuality {
        assessHumanMove(move, before: engine, hardness: hardness).quality
    }

    static func assessHumanMove(_ move: Cell, before engine: GameEngine, hardness: Int) -> HumanMoveAssessment {
        guard engine.currentPlayer == .x, engine.canPlay(at: move) else {
            return HumanMoveAssessment(quality: .blunder, reason: .weakMove(rank: 0, total: 1))
        }

        var afterMove = engine
        if let result = try? afterMove.place(at: move), case .won(.x) = result {
            return HumanMoveAssessment(quality: .excellent, reason: .strongMove(rank: 0, total: 1))
        }

        if let winCell = immediateWinningMoveSearchingFullBoard(for: engine), winCell != move {
            return HumanMoveAssessment(quality: .blunder, reason: .missedImmediateWin)
        }

        var afterHuman = engine
        _ = try? afterHuman.place(at: move)
        if afterHuman.result == .ongoing {
            let opponentTurn = GameEngine(
                settings: afterHuman.settings,
                cells: afterHuman.cells,
                currentPlayer: .o,
                result: afterHuman.result
            )
            if immediateWinningMoveSearchingFullBoard(for: opponentTurn) != nil {
                return HumanMoveAssessment(quality: .blunder, reason: .oneMoveFromLoss)
            }
        }

        let candidates = candidateCells(for: engine)
        guard candidates.count > 1 else {
            return HumanMoveAssessment(
                quality: .mediocre,
                reason: .weakMove(rank: 0, total: 1)
            )
        }

        let ranked = rankMoves(candidates, engine: engine)

        guard let index = ranked.firstIndex(where: { $0.0 == move }) else {
            return HumanMoveAssessment(
                quality: .mediocre,
                reason: .weakMove(rank: ranked.count / 2, total: ranked.count)
            )
        }

        let total = ranked.count
        let moveScore = ranked[index].1
        let percentile = Double(index) / Double(max(total - 1, 1))
        let quality: HumanMoveQuality
        switch percentile {
        case ...0.15: quality = .excellent
        case ...0.35: quality = .good
        case ...0.65: quality = .mediocre
        default: quality = .poor
        }

        let notable = isTacticallyNotable(
            moveScore: moveScore,
            rank: index,
            ranked: ranked,
            stonesOnBoard: engine.cells.count
        )

        let reason: HumanMoveReason
        switch quality {
        case .excellent, .good:
            reason = .strongMove(rank: index, total: total)
        case .mediocre, .poor, .blunder:
            reason = .weakMove(rank: index, total: total)
        }

        return HumanMoveAssessment(quality: quality, reason: reason, isTacticallyNotable: notable)
    }

    private static func isTacticallyNotable(
        moveScore: Int,
        rank: Int,
        ranked: [(Cell, Int)],
        stonesOnBoard: Int
    ) -> Bool {
        guard stonesOnBoard >= 4 else { return false }

        if moveScore >= 5_000 { return true }

        guard rank <= 1 else { return false }

        let bestScore = ranked[0].1
        let secondScore = ranked.count > 1 ? ranked[1].1 : Int.min

        if rank == 1, bestScore - moveScore > 50 { return false }

        if moveScore >= 2_500 { return true }

        guard rank == 0, moveScore >= 900 else { return false }

        if ranked.count >= 3, bestScore - ranked[2].1 < 120 { return false }
        if ranked.count >= 2, bestScore - secondScore < 80 { return false }

        return stonesOnBoard >= 6
    }

    private static func candidateCells(for engine: GameEngine) -> [Cell] {
        let dim = engine.settings.boardSize.dimension
        if dim > 3 {
            return neighborhoodCandidates(engine: engine, dimension: dim)
        }
        return allCellsInBounds(dimension: dim).filter { engine.canPlay(at: $0) }
    }

    private static func neighborhoodRadius(for dimension: Int) -> Int {
        switch dimension {
        case ...5: return 1
        case ...10: return 2
        default: return 2
        }
    }

    private static func allCellsInBounds(dimension: Int) -> [Cell] {
        (0..<dimension).flatMap { y in
            (0..<dimension).map { x in Cell(x: x, y: y) }
        }
    }

    private static func neighborhoodCandidates(engine: GameEngine, dimension: Int) -> [Cell] {
        let radius = neighborhoodRadius(for: dimension)
        guard !engine.cells.isEmpty else {
            let center = dimension / 2
            return (-radius...radius).flatMap { dy in
                (-radius...radius).map { dx in Cell(x: center + dx, y: center + dy) }
            }.filter { engine.canPlay(at: $0) }
        }

        var set = Set<Cell>()
        for (cell, _) in engine.cells {
            for dx in -radius...radius {
                for dy in -radius...radius {
                    let candidate = Cell(x: cell.x + dx, y: cell.y + dy)
                    if engine.canPlay(at: candidate) {
                        set.insert(candidate)
                    }
                }
            }
        }
        return Array(set)
    }

    private static func aiLevel(from hardness: Int) -> Int {
        min(5, max(0, hardness * 5 / 100))
    }

    private static func extraSearchDepth(from hardness: Int) -> Int {
        min(1, max(0, (min(AdaptiveDifficulty.maxHardness, hardness) - 100) / 50))
    }

    private static func searchDepth(for engine: GameEngine, hardness: Int) -> Int {
        let dim = engine.settings.boardSize.dimension
        let emptyCells = dim * dim - engine.cells.count
        let level = aiLevel(from: hardness)
        let bonus = extraSearchDepth(from: hardness)

        let baseDepth: Int
        switch dim {
        case ...3:
            baseDepth = emptyCells
        case ...5:
            baseDepth = min(3, emptyCells)
        case ...10:
            baseDepth = min(3, emptyCells)
        default:
            baseDepth = min(2, emptyCells)
        }

        let depth: Int
        switch level {
        case 5: depth = baseDepth
        case 4: depth = max(usesMinimaxSearch(for: engine) ? 1 : 0, baseDepth - 1)
        case 3: depth = max(usesMinimaxSearch(for: engine) ? 1 : 0, baseDepth - 2)
        case 2: depth = usesMinimaxSearch(for: engine) ? max(1, min(2, baseDepth - 3)) : 0
        default: depth = 0
        }

        return min(depth + bonus, emptyCells)
    }

    private static func rankWithMinimax(_ moves: [Cell], engine: GameEngine, depth: Int) -> [(Cell, Int)] {
        let limit = maxRootMoves(for: engine)
        let ordered = moves
            .sorted { heuristic(move: $0, engine: engine) > heuristic(move: $1, engine: engine) }
        let rootMoves = Array(ordered.prefix(limit))
        let aiMark = engine.currentPlayer

        return rootMoves.map { move in
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

        let candidates = searchCandidates(for: engine)
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

    private static func maxRootMoves(for engine: GameEngine) -> Int {
        switch engine.settings.boardSize.dimension {
        case ...3: return 9
        case ...5: return 8
        case ...10: return 8
        default: return 10
        }
    }

    private static func searchCandidates(for engine: GameEngine) -> [Cell] {
        let cells = candidateCells(for: engine)
        let limit = maxRootMoves(for: engine)
        guard cells.count > limit else { return cells }
        return Array(
            cells.sorted { proximityScore($0, engine: engine) > proximityScore($1, engine: engine) }
                .prefix(limit)
        )
    }

    private static func proximityScore(_ move: Cell, engine: GameEngine) -> Int {
        var score = 0
        for (cell, _) in engine.cells {
            let distance = abs(move.x - cell.x) + abs(move.y - cell.y)
            switch distance {
            case 1: score += 60
            case 2: score += 28
            case 3: score += 10
            default: break
            }
        }

        let dimension = engine.settings.boardSize.dimension
        let center = (dimension - 1) / 2
        score += max(0, 14 - (abs(move.x - center) + abs(move.y - center)))
        return score
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

    private static func immediateWinningMoveSearchingFullBoard(for engine: GameEngine) -> Cell? {
        let dimension = engine.settings.boardSize.dimension
        for move in allCellsInBounds(dimension: dimension) where engine.canPlay(at: move) {
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

    private static func selectMove(from ranked: [(Cell, Int)], hardness: Int) -> Cell {
        guard let best = ranked.first?.0 else { return Cell(x: 0, y: 0) }
        let top = ranked.prefix(3).map(\.0)
        let level = aiLevel(from: hardness)

        switch level {
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
