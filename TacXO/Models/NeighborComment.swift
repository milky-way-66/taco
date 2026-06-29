import Foundation

struct NeighborComment: Equatable, Hashable {
    let text: String
    let mood: NeighborCommentMood
}

enum NeighborCommentMood: Equatable, Hashable {
    case impressed
    case neutral
    case disappointed
}

extension HumanMoveQuality {
    var commentMood: NeighborCommentMood {
        switch self {
        case .excellent, .good:
            return .impressed
        case .mediocre:
            return .neutral
        case .poor, .blunder:
            return .disappointed
        }
    }
}
