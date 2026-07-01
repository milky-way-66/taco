import Foundation

struct GameInvite: Codable, Equatable {
    let settings: GameSettings
    let hostParticipantID: String
}

struct NearbyGameState: Codable, Equatable {
    let cells: [Cell: Mark]
    let currentPlayer: Mark
    let result: GameResult
    let winningCells: Set<Cell>

    init(cells: [Cell: Mark], currentPlayer: Mark, result: GameResult, winningCells: Set<Cell>) {
        self.cells = cells
        self.currentPlayer = currentPlayer
        self.result = result
        self.winningCells = winningCells
    }

    init(engine: GameEngine) {
        cells = engine.cells
        currentPlayer = engine.currentPlayer
        result = engine.result
        winningCells = engine.winningCells
    }
}

enum NearbyGameMessage: Codable, Equatable {
    case invite(GameInvite)
    case moveRequest(Cell)
    case gameState(NearbyGameState)
    case forfeit
    case rematchRequest
    case rematchAccepted(GameInvite)

    private enum CodingKeys: String, CodingKey { case type, invite, cell, state }

    private enum MessageType: String, Codable {
        case invite, moveRequest, gameState, forfeit, rematchRequest, rematchAccepted
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        switch try container.decode(MessageType.self, forKey: .type) {
        case .invite:
            self = .invite(try container.decode(GameInvite.self, forKey: .invite))
        case .moveRequest:
            self = .moveRequest(try container.decode(Cell.self, forKey: .cell))
        case .gameState:
            self = .gameState(try container.decode(NearbyGameState.self, forKey: .state))
        case .forfeit:
            self = .forfeit
        case .rematchRequest:
            self = .rematchRequest
        case .rematchAccepted:
            self = .rematchAccepted(try container.decode(GameInvite.self, forKey: .invite))
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .invite(let invite):
            try container.encode(MessageType.invite, forKey: .type)
            try container.encode(invite, forKey: .invite)
        case .moveRequest(let cell):
            try container.encode(MessageType.moveRequest, forKey: .type)
            try container.encode(cell, forKey: .cell)
        case .gameState(let state):
            try container.encode(MessageType.gameState, forKey: .type)
            try container.encode(state, forKey: .state)
        case .forfeit:
            try container.encode(MessageType.forfeit, forKey: .type)
        case .rematchRequest:
            try container.encode(MessageType.rematchRequest, forKey: .type)
        case .rematchAccepted(let invite):
            try container.encode(MessageType.rematchAccepted, forKey: .type)
            try container.encode(invite, forKey: .invite)
        }
    }
}
