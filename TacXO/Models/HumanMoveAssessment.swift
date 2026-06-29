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
    /// Praise comments only fire when a move is tactically meaningful, not just ranked well.
    let isTacticallyNotable: Bool

    init(
        quality: HumanMoveQuality,
        reason: HumanMoveReason,
        isTacticallyNotable: Bool = false
    ) {
        self.quality = quality
        self.reason = reason
        self.isTacticallyNotable = isTacticallyNotable
    }

    var shouldComment: Bool {
        switch reason {
        case .missedImmediateWin, .oneMoveFromLoss:
            return true
        case .strongMove:
            return isTacticallyNotable && (quality == .excellent || quality == .good)
        case .weakMove:
            return false
        }
    }
}
