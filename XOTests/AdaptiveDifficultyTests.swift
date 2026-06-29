import XCTest
@testable import XO

final class AdaptiveDifficultyTests: XCTestCase {
    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: "xo.neighbor.difficulty")
    }

    func testDefaultLevelIsFive() {
        let d = AdaptiveDifficulty()
        XCTAssertEqual(d.level, 5)
    }

    func testDecreaseOnLossFloorsAtZero() {
        var d = AdaptiveDifficulty()
        for _ in 0..<10 { d.recordLoss() }
        XCTAssertEqual(d.level, 0)
    }

    func testIncreaseOnWinCapsAtFive() {
        var d = AdaptiveDifficulty()
        d.recordLoss()
        d.recordLoss()
        for _ in 0..<10 { d.recordWin() }
        XCTAssertEqual(d.level, 5)
    }

    func testPersistsAcrossInstances() {
        var d = AdaptiveDifficulty()
        d.recordLoss()
        d.recordLoss()
        let d2 = AdaptiveDifficulty()
        XCTAssertEqual(d2.level, 3)
    }
}
