import Foundation

struct AdaptiveDifficulty {
    static let defaultHardness = 100
    static let minHardness = 0
    static let maxHardness = 200
    static let streakFireThreshold = 2

    private static let hardnessKey = "xo.neighbor.hardness"
    private static let winStreakKey = "xo.neighbor.winStreak"
    private static let legacyLevelKey = "xo.neighbor.difficulty"
    private static let legacyLossStreakKey = "xo.neighbor.lossStreak"

    private(set) var hardnessPercent: Int
    private(set) var winStreak: Int

    init() {
        if let stored = UserDefaults.standard.object(forKey: Self.hardnessKey) as? Int {
            hardnessPercent = Self.clamped(stored)
        } else if let legacyLevel = UserDefaults.standard.object(forKey: Self.legacyLevelKey) as? Int {
            hardnessPercent = Self.clamped(legacyLevel * 20)
            UserDefaults.standard.removeObject(forKey: Self.legacyLevelKey)
            UserDefaults.standard.removeObject(forKey: Self.legacyLossStreakKey)
        } else {
            hardnessPercent = Self.defaultHardness
        }

        winStreak = UserDefaults.standard.integer(forKey: Self.winStreakKey)

        if UserDefaults.standard.object(forKey: Self.hardnessKey) == nil {
            save()
        }
    }

    @discardableResult
    mutating func recordLoss() -> Int {
        hardnessPercent = max(Self.minHardness, hardnessPercent - 1)
        winStreak = 0
        save()
        return -1
    }

    @discardableResult
    mutating func recordWin() -> Int {
        hardnessPercent = min(Self.maxHardness, hardnessPercent + 1)
        winStreak += 1
        save()
        return 1
    }

    private func save() {
        UserDefaults.standard.set(hardnessPercent, forKey: Self.hardnessKey)
        UserDefaults.standard.set(winStreak, forKey: Self.winStreakKey)
    }

    private static func clamped(_ value: Int) -> Int {
        min(maxHardness, max(minHardness, value))
    }
}
