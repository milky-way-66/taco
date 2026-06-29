import Foundation

/// Ông Sáu — the grumpy Northern Vietnamese neighbor over the fence.
enum Neighbor {
    static func name(for language: AppLanguage) -> String {
        String(localized: "neighbor_name", locale: language.locale)
    }
}

/// How Uncle Sáu addresses the player — tone shifts with the moment.
enum NeighborPlayerAddress {
    case happy
    case normal
    case angry

    func term(for language: AppLanguage) -> String {
        switch language.effectiveLanguageCode {
        case "vi":
            switch self {
            case .happy: return "nhóc"
            case .normal: return "mày"
            case .angry: return "thằng này"
            }
        default:
            switch self {
            case .happy: return "kid"
            case .normal: return "you"
            case .angry: return "this guy"
            }
        }
    }

    static func forAssessment(_ assessment: HumanMoveAssessment) -> NeighborPlayerAddress {
        switch assessment.reason {
        case .missedImmediateWin, .oneMoveFromLoss:
            return .angry
        case .strongMove:
            return assessment.quality == .excellent ? .happy : .normal
        case .weakMove:
            return .normal
        }
    }
}
