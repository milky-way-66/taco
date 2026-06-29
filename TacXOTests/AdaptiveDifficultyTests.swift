import XCTest
@testable import TacXO

final class AdaptiveDifficultyTests: XCTestCase {
    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: "xo.neighbor.hardness")
        UserDefaults.standard.removeObject(forKey: "xo.neighbor.winStreak")
        UserDefaults.standard.removeObject(forKey: "xo.neighbor.difficulty")
        UserDefaults.standard.removeObject(forKey: "xo.neighbor.lossStreak")
    }

    func testDefaultHardnessIsOneHundred() {
        let d = AdaptiveDifficulty()
        XCTAssertEqual(d.hardnessPercent, 100)
        XCTAssertEqual(d.winStreak, 0)
    }

    func testLossDecreasesByOneFloorsAtZero() {
        var d = AdaptiveDifficulty()
        for _ in 0..<120 { d.recordLoss() }
        XCTAssertEqual(d.hardnessPercent, 0)
    }

    func testSingleLossDecreasesByOneAndResetsWinStreak() {
        var d = AdaptiveDifficulty()
        d.recordWin()
        d.recordWin()
        let delta = d.recordLoss()
        XCTAssertEqual(delta, -1)
        XCTAssertEqual(d.hardnessPercent, 101)
        XCTAssertEqual(d.winStreak, 0)
    }

    func testWinIncreasesByOneCapsAtTwoHundred() {
        var d = AdaptiveDifficulty()
        for _ in 0..<120 { d.recordWin() }
        XCTAssertEqual(d.hardnessPercent, 200)
    }

    func testSingleWinIncreasesByOneAndBuildsStreak() {
        var d = AdaptiveDifficulty()
        let delta = d.recordWin()
        XCTAssertEqual(delta, 1)
        XCTAssertEqual(d.hardnessPercent, 101)
        XCTAssertEqual(d.winStreak, 1)
    }

    func testConsecutiveWinsBuildStreak() {
        var d = AdaptiveDifficulty()
        d.recordWin()
        d.recordWin()
        d.recordWin()
        XCTAssertEqual(d.winStreak, 3)
    }

    func testPersistsAcrossInstances() {
        var d = AdaptiveDifficulty()
        d.recordLoss()
        d.recordWin()
        d.recordWin()
        let d2 = AdaptiveDifficulty()
        XCTAssertEqual(d2.hardnessPercent, 101)
        XCTAssertEqual(d2.winStreak, 2)
    }

    func testMigratesLegacyLevelToHardness() {
        UserDefaults.standard.set(4, forKey: "xo.neighbor.difficulty")
        let d = AdaptiveDifficulty()
        XCTAssertEqual(d.hardnessPercent, 80)
        XCTAssertNil(UserDefaults.standard.object(forKey: "xo.neighbor.difficulty"))
    }
}
