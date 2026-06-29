import Foundation

struct AdaptiveDifficulty {
    private static let levelKey = "xo.neighbor.difficulty"
    private static let lossStreakKey = "xo.neighbor.lossStreak"
    private static let lossesPerDrop = 6

    private(set) var level: Int
    private var lossStreak: Int

    init() {
        if let stored = UserDefaults.standard.object(forKey: Self.levelKey) as? Int {
            level = stored
        } else {
            level = 5
        }
        lossStreak = UserDefaults.standard.integer(forKey: Self.lossStreakKey)
        if UserDefaults.standard.object(forKey: Self.levelKey) == nil {
            save()
        }
    }

    mutating func recordLoss() {
        lossStreak += 1
        if lossStreak >= Self.lossesPerDrop {
            level = max(0, level - 1)
            lossStreak = 0
        }
        save()
    }

    mutating func recordWin() {
        lossStreak = 0
        level = min(5, level + 1)
        save()
    }

    private func save() {
        UserDefaults.standard.set(level, forKey: Self.levelKey)
        UserDefaults.standard.set(lossStreak, forKey: Self.lossStreakKey)
    }
}
