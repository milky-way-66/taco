import Foundation

/// Picks from a pool in shuffled order without repeating until the pool is exhausted.
struct ShuffledBag<T: Hashable> {
    private var queue: [T] = []
    private var last: T?
    private let source: [T]

    init(_ source: [T]) {
        self.source = source
    }

    mutating func next() -> T {
        precondition(!source.isEmpty, "ShuffledBag needs a non-empty source")
        if queue.isEmpty {
            queue = source.shuffled()
            if let last, queue.count > 1, queue[0] == last {
                queue.swapAt(0, queue.count - 1)
            }
        }
        let pick = queue.removeFirst()
        last = pick
        return pick
    }

    mutating func reset() {
        queue = []
        last = nil
    }
}

/// Tracks Uncle Sáu's speech so lines do not repeat back-to-back across games.
struct NeighborSpeechVariety {
    private var defeatQuoteIndices: ShuffledBag<Int>
    private var winQuoteIndices: ShuffledBag<Int>
    private var moveCommentIndices: [String: ShuffledBag<Int>] = [:]

    init() {
        defeatQuoteIndices = ShuffledBag(Array(NeighborQuotes.all.indices))
        winQuoteIndices = ShuffledBag(Array(NeighborWinQuotes.all.indices))
    }

    mutating func nextDefeatQuote() -> NeighborQuote {
        NeighborQuotes.all[defeatQuoteIndices.next()]
    }

    mutating func nextWinQuote() -> NeighborQuote {
        NeighborWinQuotes.all[winQuoteIndices.next()]
    }

    mutating func resetGameComments() {
        moveCommentIndices = [:]
    }

    mutating func nextMoveCommentIndex(poolKey: String, poolSize: Int) -> Int {
        guard poolSize > 0 else { return 0 }
        if moveCommentIndices[poolKey] == nil {
            moveCommentIndices[poolKey] = ShuffledBag(Array(0..<poolSize))
        }
        return moveCommentIndices[poolKey]!.next()
    }
}
