import Foundation

struct AdaptiveDifficulty {
    private static let storageKey = "xo.neighbor.difficulty"
    private(set) var level: Int

    init() {
        if let stored = UserDefaults.standard.object(forKey: Self.storageKey) as? Int {
            level = stored
        } else {
            level = 5
            save()
        }
    }

    mutating func recordLoss() {
        level = max(0, level - 1)
        save()
    }

    mutating func recordWin() {
        level = min(5, level + 1)
        save()
    }

    private func save() {
        UserDefaults.standard.set(level, forKey: Self.storageKey)
    }
}
