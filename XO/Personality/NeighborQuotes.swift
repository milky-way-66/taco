import Foundation

enum NeighborQuotes {
    static let all: [String] = [
        "My dead dog plays better.",
        "You call that thinking?",
        "Back in my day we had brains.",
        "I've seen fence posts smarter than you.",
        "Keep practicing. You'll get worse.",
        "That move smelled funny. Like you.",
        "Did your mom teach you that?",
        "Ha! Kids these days.",
        "You bored me to death.",
        "Even my lawn gnome would win.",
        "Try using your head next time.",
        "Pathetic. Truly pathetic.",
        "I almost felt sorry. Almost.",
        "You play like my arthritic uncle.",
        "Go back to kindergarten.",
        "Was that on purpose? Hope not.",
        "My garbage plays harder than you.",
        "You make losing look easy.",
        "I've had better naps than this game.",
        "Stick to hopscotch, kid."
    ]

    static func random() -> String {
        all.randomElement() ?? "Ha!"
    }
}
