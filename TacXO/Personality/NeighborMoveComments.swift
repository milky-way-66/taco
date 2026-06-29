import Foundation

struct NeighborMoveComment: Equatable {
    let english: String
    let vietnamese: String

    func text(for language: AppLanguage) -> String {
        language.effectiveLanguageCode == "vi" ? vietnamese : english
    }
}

enum NeighborMoveComments {
    static func comment(
        for assessment: HumanMoveAssessment,
        move: Cell,
        moveNumber: Int,
        language: AppLanguage
    ) -> String? {
        guard assessment.shouldComment else { return nil }

        let pool: [NeighborMoveComment]
        switch assessment.reason {
        case .missedImmediateWin:
            pool = missedWin
        case .allowedOpponentWin:
            pool = allowedOpponentWin
        case .strongMove:
            pool = assessment.quality == .excellent ? excellentMove : goodMove
        case .weakMove:
            return nil
        }

        let index = selectionIndex(move: move, moveNumber: moveNumber, poolSize: pool.count)
        return pool[index].text(for: language)
    }

    private static func selectionIndex(move: Cell, moveNumber: Int, poolSize: Int) -> Int {
        guard poolSize > 0 else { return 0 }
        return (move.x * 7 + move.y * 13 + moveNumber) % poolSize
    }

    private static let missedWin: [NeighborMoveComment] = [
        NeighborMoveComment(
            english: "The win was right there. Are you blind?",
            vietnamese: "Thắng ngon ăn mà còn không lấy — mù à?"
        ),
        NeighborMoveComment(
            english: "You had one job. Take the win.",
            vietnamese: "Một việc duy nhất: ăn thắng. Mày làm không nổi."
        ),
        NeighborMoveComment(
            english: "Know yourself? Clearly not.",
            vietnamese: "Biết người biết ta — mày biết gì?"
        ),
        NeighborMoveComment(
            english: "One look and I know you're done.",
            vietnamese: "Nhìn cái nước này là bố biết mày hết thuốc chữa rồi."
        ),
    ]

    private static let allowedOpponentWin: [NeighborMoveComment] = [
        NeighborMoveComment(
            english: "You just handed me the game.",
            vietnamese: "Mày tự đưa bàn thắng cho bố rồi."
        ),
        NeighborMoveComment(
            english: "Are you throwing the game on purpose?",
            vietnamese: "Bố nghi mày cố tình thua để bố đỡ phải nói nhiều."
        ),
        NeighborMoveComment(
            english: "Play with fire, get burned.",
            vietnamese: "Chơi dao có ngày đứt tay — mày cầm dao mà tự chém mình."
        ),
        NeighborMoveComment(
            english: "That move smelled funny. Like you.",
            vietnamese: "Nước này đúng là tự đào mồ chôn thân."
        ),
    ]

    private static let excellentMove: [NeighborMoveComment] = [
        NeighborMoveComment(
            english: "Better than I expected.",
            vietnamese: "Khá đấy — tưởng mày dốt đặc cán mai."
        ),
        NeighborMoveComment(
            english: "Hmph. Not completely hopeless.",
            vietnamese: "Hừm. Chưa đến nỗi phế vật."
        ),
        NeighborMoveComment(
            english: "You almost look like you thought.",
            vietnamese: "Nhìn cũng ra có sỏi trong đầu."
        ),
        NeighborMoveComment(
            english: "Near ink, still not black. Impressive.",
            vietnamese: "Gần mực thì đen — mày gần bố mà cũng ra phát này."
        ),
    ]

    private static let goodMove: [NeighborMoveComment] = [
        NeighborMoveComment(
            english: "Fine. I'll allow it.",
            vietnamese: "Tạm. Bố cho qua lần này."
        ),
        NeighborMoveComment(
            english: "Don't get cocky. One move.",
            vietnamese: "Đừng lên mặt. Mới được có một nước cờ."
        ),
        NeighborMoveComment(
            english: "Slow and steady — you almost got it.",
            vietnamese: "Chậm mà chắc — lần này tạm được."
        ),
        NeighborMoveComment(
            english: "Even a blind chicken finds grain sometimes.",
            vietnamese: "Gà mù đụng trúng — đừng tưởng bở."
        ),
    ]
}
