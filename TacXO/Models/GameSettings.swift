import Foundation

enum BoardSize: String, Codable, CaseIterable, Identifiable {
    case three = "3×3"
    case five = "5×5"
    case ten = "10×10"

    var id: String { rawValue }

    var dimension: Int {
        switch self {
        case .three: return 3
        case .five: return 5
        case .ten: return 10
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        if let size = BoardSize(rawValue: value) {
            self = size
        } else if value == "∞" || value == "25×25" {
            self = .ten
        } else {
            self = .ten
        }
    }
}

enum GameMode: String, Codable, CaseIterable, Identifiable {
    case twoPlayer
    case vsNeighbor

    var id: String { rawValue }

    var labelKey: String {
        switch self {
        case .twoPlayer: return "mode_two_player"
        case .vsNeighbor: return "mode_vs_neighbor"
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        switch value {
        case "twoPlayer", "2 Players":
            self = .twoPlayer
        case "vsNeighbor", "vs Neighbor":
            self = .vsNeighbor
        default:
            self = .vsNeighbor
        }
    }
}

struct GameSettings: Codable, Equatable {
    var winLength: Int = 5
    var boardSize: BoardSize = .ten
    var mode: GameMode = .vsNeighbor
    var language: AppLanguage = .system

    static let `default` = GameSettings()

    private static let storageKey = "tacxo.game.settings"

    static func load() -> GameSettings {
        guard
            let data = UserDefaults.standard.data(forKey: storageKey),
            let settings = try? JSONDecoder().decode(GameSettings.self, from: data)
        else {
            return .default
        }
        return settings
    }

    func save() {
        guard let data = try? JSONEncoder().encode(self) else { return }
        UserDefaults.standard.set(data, forKey: Self.storageKey)
    }
}
