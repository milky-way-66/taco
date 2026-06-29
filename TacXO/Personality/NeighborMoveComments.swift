import Foundation

struct NeighborMoveComment: Equatable {
    let englishFormat: String
    let vietnameseFormat: String

    func text(for language: AppLanguage, address: NeighborPlayerAddress) -> String {
        let format = language.effectiveLanguageCode == "vi" ? vietnameseFormat : englishFormat
        return String(format: format, address.term(for: language))
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

        let address = NeighborPlayerAddress.forAssessment(assessment)
        let pool: [NeighborMoveComment]
        switch assessment.reason {
        case .missedImmediateWin:
            pool = missedWin
        case .oneMoveFromLoss:
            pool = oneMoveFromLoss
        case .strongMove:
            pool = assessment.quality == .excellent ? excellentMove : goodMove
        case .weakMove:
            return nil
        }

        let index = selectionIndex(move: move, moveNumber: moveNumber, poolSize: pool.count)
        return pool[index].text(for: language, address: address)
    }

    private static func selectionIndex(move: Cell, moveNumber: Int, poolSize: Int) -> Int {
        guard poolSize > 0 else { return 0 }
        return (move.x * 7 + move.y * 13 + moveNumber) % poolSize
    }

    private static let missedWin: [NeighborMoveComment] = [
        NeighborMoveComment(
            englishFormat: "The win was right there, %@. Are you blind?",
            vietnameseFormat: "Thắng ngon ăn mà %@ còn không lấy — mù à?"
        ),
        NeighborMoveComment(
            englishFormat: "%@ had one job. Take the win.",
            vietnameseFormat: "Một việc duy nhất: ăn thắng. %@ làm không nổi."
        ),
        NeighborMoveComment(
            englishFormat: "Know yourself, %@? Clearly not.",
            vietnameseFormat: "Biết người biết ta — %@ biết gì?"
        ),
        NeighborMoveComment(
            englishFormat: "One look and I know %@'s done.",
            vietnameseFormat: "Nhìn cái nước này là bố biết %@ hết thuốc chữa rồi."
        ),
    ]

    private static let oneMoveFromLoss: [NeighborMoveComment] = [
        NeighborMoveComment(
            englishFormat: "No way to win now, %@. One more move.",
            vietnameseFormat: "Không còn đường thoát %@ — một nước nữa là xong."
        ),
        NeighborMoveComment(
            englishFormat: "%@ just handed me the game.",
            vietnameseFormat: "%@ tự đưa bàn thắng cho bố rồi."
        ),
        NeighborMoveComment(
            englishFormat: "Game over, %@. You just don't know it yet.",
            vietnameseFormat: "Xong rồi %@ — thua rồi, chỉ chưa biết thôi."
        ),
        NeighborMoveComment(
            englishFormat: "%@ throwing the game on purpose?",
            vietnameseFormat: "Bố nghi %@ cố tình thua để bố đỡ phải nói nhiều."
        ),
        NeighborMoveComment(
            englishFormat: "That move smelled funny. Like %@.",
            vietnameseFormat: "Nước này %@ tự đào mồ chôn thân."
        ),
    ]

    private static let excellentMove: [NeighborMoveComment] = [
        NeighborMoveComment(
            englishFormat: "Better than I expected, %@.",
            vietnameseFormat: "Khá đấy %@ — tưởng dốt đặc cán mai."
        ),
        NeighborMoveComment(
            englishFormat: "Hmph. %@'s not completely hopeless.",
            vietnameseFormat: "Hừm. %@ chưa đến nỗi phế vật."
        ),
        NeighborMoveComment(
            englishFormat: "%@ almost looks like you thought.",
            vietnameseFormat: "%@ nhìn cũng ra có sỏi trong đầu."
        ),
        NeighborMoveComment(
            englishFormat: "Near ink, still not black. Not bad, %@.",
            vietnameseFormat: "Gần mực thì đen — %@ gần bố mà cũng ra phát này."
        ),
    ]

    private static let goodMove: [NeighborMoveComment] = [
        NeighborMoveComment(
            englishFormat: "Fine, %@. I'll allow it.",
            vietnameseFormat: "Tạm %@, bố cho qua lần này."
        ),
        NeighborMoveComment(
            englishFormat: "Don't get cocky, %@. One move.",
            vietnameseFormat: "Đừng lên mặt %@. Mới được có một nước cờ."
        ),
        NeighborMoveComment(
            englishFormat: "Slow and steady — %@ almost got it.",
            vietnameseFormat: "Chậm mà chắc %@ — lần này tạm được."
        ),
        NeighborMoveComment(
            englishFormat: "Even a blind chicken finds grain sometimes, %@.",
            vietnameseFormat: "Gà mù đụng trúng — %@ đừng tưởng bở."
        ),
    ]
}
