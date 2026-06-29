import Foundation

enum HumanMoveReason: Equatable {
    case missedImmediateWin
    case oneMoveFromLoss
    case strongMove(rank: Int, total: Int)
    case weakMove(rank: Int, total: Int)
}

struct HumanMoveAssessment: Equatable {
    let quality: HumanMoveQuality
    let reason: HumanMoveReason

    var shouldComment: Bool {
        switch reason {
        case .missedImmediateWin, .oneMoveFromLoss:
            return true
        case .strongMove:
            return quality == .excellent || quality == .good
        case .weakMove:
            return false
        }
    }
}
