import XCTest
@testable import TacXO

@MainActor
final class NearbyGameControllerTests: XCTestCase {
    func testHostRejectsMoveWhenNotPlayersTurn() {
        var settings = GameSettings.default
        settings.mode = .nearbyPvP
        let controller = NearbyGameController(settings: settings)
        controller.applyRemoteState(NearbyGameState(
            cells: [:],
            currentPlayer: .o,
            result: .ongoing,
            winningCells: []
        ))
        let accepted = controller.hostValidateMove(at: Cell(x: 0, y: 0), by: .x)
        XCTAssertFalse(accepted)
    }

    func testHostAcceptsValidMove() {
        var settings = GameSettings.default
        settings.mode = .nearbyPvP
        let controller = NearbyGameController(settings: settings)
        controller.applyRemoteState(NearbyGameState(
            cells: [:],
            currentPlayer: .x,
            result: .ongoing,
            winningCells: []
        ))
        let accepted = controller.hostValidateMove(at: Cell(x: 0, y: 0), by: .x)
        XCTAssertTrue(accepted)
    }
}
