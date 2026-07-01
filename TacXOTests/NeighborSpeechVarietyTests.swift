import XCTest
@testable import TacXO

final class NeighborSpeechVarietyTests: XCTestCase {
    func testDefeatQuotesDoNotRepeatBackToBack() {
        var variety = NeighborSpeechVariety()
        let first = variety.nextDefeatQuote()
        let second = variety.nextDefeatQuote()
        XCTAssertNotEqual(first, second)
    }

    func testWinQuotesDoNotRepeatBackToBack() {
        var variety = NeighborSpeechVariety()
        let first = variety.nextWinQuote()
        let second = variety.nextWinQuote()
        XCTAssertNotEqual(first, second)
    }

    func testMoveCommentsCycleWithoutImmediateRepeat() {
        var variety = NeighborSpeechVariety()
        let poolSize = 4
        var seen = Set<Int>()
        for _ in 0..<poolSize {
            let index = variety.nextMoveCommentIndex(poolKey: "goodMove", poolSize: poolSize)
            XCTAssertFalse(seen.contains(index))
            seen.insert(index)
        }
        let afterCycle = variety.nextMoveCommentIndex(poolKey: "goodMove", poolSize: poolSize)
        XCTAssertNotEqual(afterCycle, seen.sorted().last)
    }

    func testResetGameCommentsStartsFreshPools() {
        var variety = NeighborSpeechVariety()
        _ = variety.nextMoveCommentIndex(poolKey: "missedWin", poolSize: 4)
        variety.resetGameComments()
        let index = variety.nextMoveCommentIndex(poolKey: "missedWin", poolSize: 4)
        XCTAssertTrue((0..<4).contains(index))
    }
}
