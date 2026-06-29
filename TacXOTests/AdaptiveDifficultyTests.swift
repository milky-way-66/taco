import XCTest
@testable import TacXO

final class AdaptiveDifficultyTests: XCTestCase {
    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: "xo.neighbor.difficulty")
        UserDefaults.standard.removeObject(forKey: "xo.neighbor.lossStreak")
    }

    func testDefaultLevelIsFive() {
        let d = AdaptiveDifficulty()
        XCTAssertEqual(d.level, 5)
    }

    func testDecreaseEverySixLossesFloorsAtZero() {
        var d = AdaptiveDifficulty()
        for _ in 0..<30 { d.recordLoss() }
        XCTAssertEqual(d.level, 0)
    }

    func testSingleLossDoesNotDecrease() {
        var d = AdaptiveDifficulty()
        d.recordLoss()
        XCTAssertEqual(d.level, 5)
    }

    func testSixthLossDecreasesOnce() {
        var d = AdaptiveDifficulty()
        for _ in 0..<6 { d.recordLoss() }
        XCTAssertEqual(d.level, 4)
    }

    func testIncreaseOnWinCapsAtFive() {
        var d = AdaptiveDifficulty()
        for _ in 0..<8 { d.recordLoss() }
        for _ in 0..<10 { d.recordWin() }
        XCTAssertEqual(d.level, 5)
    }

    func testWinResetsLossStreak() {
        var d = AdaptiveDifficulty()
        for _ in 0..<3 { d.recordLoss() }
        d.recordWin()
        d.recordLoss()
        XCTAssertEqual(d.level, 5)
    }

    func testPersistsAcrossInstances() {
        var d = AdaptiveDifficulty()
        for _ in 0..<6 { d.recordLoss() }
        let d2 = AdaptiveDifficulty()
        XCTAssertEqual(d2.level, 4)
    }
}
