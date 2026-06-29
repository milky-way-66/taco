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
        let assessment = HumanMoveAssessment(quality: .blunder, reason: .oneMoveFromLoss)
        let text = NeighborMoveComments.comment(
            for: assessment,
            move: Cell(x: 1, y: 1),
            moveNumber: 4,
            language: .english
        )
        XCTAssertNotNil(text)
    }

    func testOneMoveFromLossCommentIsSpecific() {
        let assessment = HumanMoveAssessment(quality: .blunder, reason: .oneMoveFromLoss)
        let text = NeighborMoveComments.comment(
            for: assessment,
            move: Cell(x: 1, y: 1),
            moveNumber: 4,
            language: .english
        )
        XCTAssertEqual(text, "That move smelled funny. Like this guy.")
    }

    func testAngryAddressInVietnamese() {
        let assessment = HumanMoveAssessment(quality: .blunder, reason: .oneMoveFromLoss)
        let text = NeighborMoveComments.comment(
            for: assessment,
            move: Cell(x: 1, y: 1),
            moveNumber: 4,
            language: .vietnamese
        )
        XCTAssertTrue(text?.contains("thằng này") == true)
    }

    func testHappyAddressInVietnamese() {
        let assessment = HumanMoveAssessment(
            quality: .excellent,
            reason: .strongMove(rank: 0, total: 4),
            isTacticallyNotable: true
        )
        let text = NeighborMoveComments.comment(
            for: assessment,
            move: Cell(x: 0, y: 0),
            moveNumber: 1,
            language: .vietnamese
        )
        XCTAssertTrue(text?.contains("nhóc") == true)
    }

    func testNormalAddressInVietnamese() {
        let assessment = HumanMoveAssessment(
            quality: .good,
            reason: .strongMove(rank: 1, total: 4),
            isTacticallyNotable: true
        )
        let text = NeighborMoveComments.comment(
            for: assessment,
            move: Cell(x: 0, y: 0),
            moveNumber: 1,
            language: .vietnamese
        )
        XCTAssertTrue(text?.contains("mày") == true)
    }

    func testMissedWinCommentUsesMissedWinPool() {
        let assessment = HumanMoveAssessment(quality: .blunder, reason: .missedImmediateWin)
        let text = NeighborMoveComments.comment(
            for: assessment,
            move: Cell(x: 2, y: 2),
            moveNumber: 3,
            language: .english
        )
        XCTAssertNotNil(text)
        let excellent = NeighborMoveComments.comment(
            for: HumanMoveAssessment(
                quality: .excellent,
                reason: .strongMove(rank: 0, total: 4),
                isTacticallyNotable: true
            ),
            move: Cell(x: 2, y: 2),
            moveNumber: 3,
            language: .english
        )
        XCTAssertNotEqual(text, excellent)
    }

    func testMediocreMoveDoesNotComment() {
        let assessment = HumanMoveAssessment(quality: .mediocre, reason: .weakMove(rank: 2, total: 5))
        let text = NeighborMoveComments.comment(
            for: assessment,
            move: Cell(x: 1, y: 1),
            moveNumber: 4,
            language: .english
        )
        XCTAssertNil(text)
    }

    func testCommentSelectionIsDeterministic() {
        let assessment = HumanMoveAssessment(
            quality: .good,
            reason: .strongMove(rank: 1, total: 4),
            isTacticallyNotable: true
        )
        let move = Cell(x: 1, y: 2)
        let first = NeighborMoveComments.comment(
            for: assessment,
            move: move,
            moveNumber: 5,
            language: .english
        )
        let second = NeighborMoveComments.comment(
            for: assessment,
            move: move,
            moveNumber: 5,
            language: .english
        )
        XCTAssertEqual(first, second)
    }

    func testExcellentAndGoodUseDifferentPools() {
        let excellent = NeighborMoveComments.comment(
            for: HumanMoveAssessment(
                quality: .excellent,
                reason: .strongMove(rank: 0, total: 4),
                isTacticallyNotable: true
            ),
            move: Cell(x: 0, y: 0),
            moveNumber: 1,
            language: .english
        )
        let good = NeighborMoveComments.comment(
            for: HumanMoveAssessment(
                quality: .good,
                reason: .strongMove(rank: 1, total: 4),
                isTacticallyNotable: true
            ),
            move: Cell(x: 0, y: 0),
            moveNumber: 1,
            language: .english
        )
        XCTAssertNotEqual(excellent, good)
    }

    func testQuietOpeningDoesNotComment() {
        let engine = GameEngine(settings: GameSettings(winLength: 5, boardSize: .ten, mode: .vsNeighbor))
        let assessment = AIPlayer.assessHumanMove(Cell(x: 5, y: 5), before: engine, hardness: 100)
        XCTAssertFalse(assessment.shouldComment)
        XCTAssertNil(
            NeighborMoveComments.comment(
                for: assessment,
                move: Cell(x: 5, y: 5),
                moveNumber: 0,
                language: .english
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
