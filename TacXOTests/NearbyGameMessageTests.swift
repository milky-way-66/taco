import XCTest
@testable import TacXO

final class NearbyGameMessageTests: XCTestCase {
    func testGameResultRoundTrip() throws {
        let results: [GameResult] = [.ongoing, .won(.x), .won(.o), .draw]
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        for result in results {
            let data = try encoder.encode(result)
            let decoded = try decoder.decode(GameResult.self, from: data)
            XCTAssertEqual(decoded, result)
        }
    }

    func testNearbyGameStateRoundTrip() throws {
        let state = NearbyGameState(
            cells: [Cell(x: 0, y: 0): .x, Cell(x: 1, y: 1): .o],
            currentPlayer: .x,
            result: .ongoing,
            winningCells: []
        )
        let data = try JSONEncoder().encode(state)
        let decoded = try JSONDecoder().decode(NearbyGameState.self, from: data)
        XCTAssertEqual(decoded, state)
    }

    func testInviteRoundTrip() throws {
        var settings = GameSettings.default
        settings.boardSize = .five
        settings.winLength = 5
        let invite = GameInvite(settings: settings, hostParticipantID: "host-abc")
        let message = NearbyGameMessage.invite(invite)
        let data = try JSONEncoder().encode(message)
        let decoded = try JSONDecoder().decode(NearbyGameMessage.self, from: data)
        XCTAssertEqual(decoded, message)
    }
}
