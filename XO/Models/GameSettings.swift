import Foundation

enum BoardSize: String, Codable, CaseIterable, Identifiable {
    case three = "3×3"
    case five = "5×5"
    case ten = "10×10"
    case infinite = "∞"

    var id: String { rawValue }

    /// nil means unbounded (infinite mode)
    var dimension: Int? {
        switch self {
        case .three: return 3
        case .five: return 5
        case .ten: return 10
        case .infinite: return nil
        }
    }
}

enum GameMode: String, Codable, CaseIterable, Identifiable {
    case twoPlayer = "2 Players"
    case vsNeighbor = "vs Neighbor"

    var id: String { rawValue }
}

struct GameSettings: Codable, Equatable {
    var winLength: Int = 5
    var boardSize: BoardSize = .five
    var mode: GameMode = .vsNeighbor

    static let `default` = GameSettings()

    private static let storageKey = "xo.game.settings"

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
