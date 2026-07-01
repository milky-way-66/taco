import XCTest
@testable import TacXO

final class MoveCommentTests: XCTestCase {
    func testDetectsMissedWinAsBlunder() {
        let engine = GameEngine(
            settings: GameSettings(winLength: 3, boardSize: .three, mode: .vsNeighbor),
            cells: [
                Cell(x: 0, y: 0): .x,
                Cell(x: 1, y: 0): .x,
                Cell(x: 0, y: 1): .o
            ],
            currentPlayer: .x
        )

        let assessment = AIPlayer.assessHumanMove(Cell(x: 2, y: 2), before: engine, hardness: 100)
        XCTAssertEqual(assessment.quality, .blunder)
        XCTAssertEqual(assessment.reason, .missedImmediateWin)
    }

    func testDetectsWinningMoveAsExcellent() {
        let engine = GameEngine(
            settings: GameSettings(winLength: 3, boardSize: .three, mode: .vsNeighbor),
            cells: [
                Cell(x: 0, y: 0): .x,
                Cell(x: 1, y: 0): .x,
                Cell(x: 0, y: 1): .o
            ],
            currentPlayer: .x
        )

        let assessment = AIPlayer.assessHumanMove(Cell(x: 2, y: 0), before: engine, hardness: 100)
        XCTAssertEqual(assessment.quality, .excellent)
    }

    func testDetectsOneMoveFromLoss() {
        let engine = GameEngine(
            settings: GameSettings(winLength: 3, boardSize: .three, mode: .vsNeighbor),
            cells: [
                Cell(x: 0, y: 0): .o,
                Cell(x: 0, y: 1): .o,
                Cell(x: 1, y: 0): .x,
                Cell(x: 2, y: 0): .x
            ],
            currentPlayer: .x
        )

        let assessment = AIPlayer.assessHumanMove(Cell(x: 1, y: 1), before: engine, hardness: 100)
        XCTAssertEqual(assessment.quality, .blunder)
        XCTAssertEqual(assessment.reason, .oneMoveFromLoss)
        XCTAssertTrue(assessment.shouldComment)
    }

    func testOneMoveFromLossAlwaysComments() {
        var variety = NeighborSpeechVariety()
        let assessment = HumanMoveAssessment(quality: .blunder, reason: .oneMoveFromLoss)
        let text = NeighborMoveComments.comment(
            for: assessment,
            language: .english,
            variety: &variety
        )
        XCTAssertNotNil(text)
    }

    func testOneMoveFromLossCommentUsesAngryAddress() {
        var variety = NeighborSpeechVariety()
        let assessment = HumanMoveAssessment(quality: .blunder, reason: .oneMoveFromLoss)
        let text = NeighborMoveComments.comment(
            for: assessment,
            language: .english,
            variety: &variety
        )
        XCTAssertTrue(text?.contains("this guy") == true)
    }

    func testAngryAddressInVietnamese() {
        var variety = NeighborSpeechVariety()
        let assessment = HumanMoveAssessment(quality: .blunder, reason: .oneMoveFromLoss)
        let text = NeighborMoveComments.comment(
            for: assessment,
            language: .vietnamese,
            variety: &variety
        )
        XCTAssertTrue(text?.contains("thằng này") == true)
    }

    func testHappyAddressInVietnamese() {
        var variety = NeighborSpeechVariety()
        let assessment = HumanMoveAssessment(
            quality: .excellent,
            reason: .strongMove(rank: 0, total: 4),
            isTacticallyNotable: true
        )
        let text = NeighborMoveComments.comment(
            for: assessment,
            language: .vietnamese,
            variety: &variety
        )
        XCTAssertTrue(text?.contains("nhóc") == true)
    }

    func testNormalAddressInVietnamese() {
        var variety = NeighborSpeechVariety()
        let assessment = HumanMoveAssessment(
            quality: .good,
            reason: .strongMove(rank: 1, total: 4),
            isTacticallyNotable: true
        )
        let text = NeighborMoveComments.comment(
            for: assessment,
            language: .vietnamese,
            variety: &variety
        )
        XCTAssertTrue(text?.contains("mày") == true)
    }

    func testMissedWinCommentUsesMissedWinPool() {
        var variety = NeighborSpeechVariety()
        let assessment = HumanMoveAssessment(quality: .blunder, reason: .missedImmediateWin)
        let text = NeighborMoveComments.comment(
            for: assessment,
            language: .english,
            variety: &variety
        )
        XCTAssertNotNil(text)
        let excellent = NeighborMoveComments.comment(
            for: HumanMoveAssessment(
                quality: .excellent,
                reason: .strongMove(rank: 0, total: 4),
                isTacticallyNotable: true
            ),
            language: .english,
            variety: &variety
        )
        XCTAssertNotEqual(text, excellent)
    }

    func testMediocreMoveDoesNotComment() {
        var variety = NeighborSpeechVariety()
        let assessment = HumanMoveAssessment(quality: .mediocre, reason: .weakMove(rank: 2, total: 5))
        let text = NeighborMoveComments.comment(
            for: assessment,
            language: .english,
            variety: &variety
        )
        XCTAssertNil(text)
    }

    func testMoveCommentsDoNotRepeatWithinPool() {
        var variety = NeighborSpeechVariety()
        let assessment = HumanMoveAssessment(
            quality: .good,
            reason: .strongMove(rank: 1, total: 4),
            isTacticallyNotable: true
        )
        var comments = Set<String>()
        for _ in 0..<4 {
            if let text = NeighborMoveComments.comment(
                for: assessment,
                language: .english,
                variety: &variety
            ) {
                comments.insert(text)
            }
        }
        XCTAssertEqual(comments.count, 4)
    }

    func testExcellentAndGoodUseDifferentPools() {
        var variety = NeighborSpeechVariety()
        let excellent = NeighborMoveComments.comment(
            for: HumanMoveAssessment(
                quality: .excellent,
                reason: .strongMove(rank: 0, total: 4),
                isTacticallyNotable: true
            ),
            language: .english,
            variety: &variety
        )
        let good = NeighborMoveComments.comment(
            for: HumanMoveAssessment(
                quality: .good,
                reason: .strongMove(rank: 1, total: 4),
                isTacticallyNotable: true
            ),
            language: .english,
            variety: &variety
        )
        XCTAssertNotEqual(excellent, good)
    }

    func testQuietOpeningDoesNotComment() {
        var variety = NeighborSpeechVariety()
        let engine = GameEngine(settings: GameSettings(winLength: 5, boardSize: .ten, mode: .vsNeighbor))
        let assessment = AIPlayer.assessHumanMove(Cell(x: 5, y: 5), before: engine, hardness: 100)
        XCTAssertFalse(assessment.shouldComment)
        XCTAssertNil(
            NeighborMoveComments.comment(
                for: assessment,
                language: .english,
                variety: &variety
            )
        )
    }

    func testRoutineMidgameMoveDoesNotComment() {
        let engine = GameEngine(
            settings: GameSettings(winLength: 5, boardSize: .ten, mode: .vsNeighbor),
            cells: [
                Cell(x: 5, y: 5): .x,
                Cell(x: 5, y: 6): .o,
                Cell(x: 6, y: 5): .x,
                Cell(x: 4, y: 6): .o,
            ],
            currentPlayer: .x
        )
        let assessment = AIPlayer.assessHumanMove(Cell(x: 7, y: 5), before: engine, hardness: 100)
        XCTAssertFalse(assessment.shouldComment)
    }

    func testBlockingOpponentWinComments() {
        let engine = GameEngine(
            settings: GameSettings(winLength: 5, boardSize: .ten, mode: .vsNeighbor),
            cells: [
                Cell(x: 4, y: 5): .o,
                Cell(x: 5, y: 5): .o,
                Cell(x: 6, y: 5): .o,
                Cell(x: 7, y: 5): .o,
                Cell(x: 5, y: 4): .x,
            ],
            currentPlayer: .x
        )
        let assessment = AIPlayer.assessHumanMove(Cell(x: 3, y: 5), before: engine, hardness: 100)
        XCTAssertTrue(assessment.shouldComment)
    }
}
