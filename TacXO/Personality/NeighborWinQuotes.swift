import Foundation

enum NeighborWinQuotes {
    /// Neighbor's salty lines when the player beats him — denial, excuses, grudging respect.
    static let all: [NeighborQuote] = [
        NeighborQuote(
            english: "Lucky. Pure luck.",
            vietnamese: "May mắn thôi! Bố cho mày thắng một bàn.",
            explanationEnglish: "Classic sore loser — claims victory was a gift, not skill.",
            explanationVietnamese: "Kiểu thua miệng Bắc: 'cho' mày thắng để giữ thể diện bố."
        ),
        NeighborQuote(
            english: "The board was crooked.",
            vietnamese: "Bàn cờ lệch — bố không thèm cãi.",
            explanationEnglish: "Blames the equipment rather than admit defeat.",
            explanationVietnamese: "Đổ lỗi hoàn cảnh — giọng Bắc hay chối khi thua."
        ),
        NeighborQuote(
            english: "I wasn't even trying.",
            vietnamese: "Bố chơi cho vui, chưa nghiêm đâu.",
            explanationEnglish: "Pretends the match didn't matter.",
            explanationVietnamese: "Hạ thấp trận đấu để cứu mặt — 'chơi cho vui'."
        ),
        NeighborQuote(
            english: "Beginner's luck, that's all.",
            vietnamese: "Trẻ con may mắn — đừng tưởng bố hết cờ.",
            explanationEnglish: "Dismisses you as a fluke beginner.",
            explanationVietnamese: "Chê là may mắn tạm thời, bố còn nhiều ván."
        ),
        NeighborQuote(
            english: "My hand slipped. Twice.",
            vietnamese: "Tay bố đau — mày thắng kiểu gì cũng được.",
            explanationEnglish: "Fake injury excuse — Northern elder playing victim.",
            explanationVietnamese: "Giả ốm, giả mệt — miễn không phải thừa nhận mày giỏi hơn."
        ),
        NeighborQuote(
            english: "Fine. You win. Happy now?",
            vietnamese: "Thắng rồi thì thắng — đừng mặt dày với bố.",
            explanationEnglish: "Grudging concession with a scold attached.",
            explanationVietnamese: "Nhượng miệng nhưng chèn lời dạy — vẫn giữ vai trên."
        ),
        NeighborQuote(
            english: "The sun was in my eyes.",
            vietnamese: "Nắng chói quá, bố nhìn không rõ — tính lại.",
            explanationEnglish: "Absurd environmental excuse.",
            explanationVietnamese: "Cớ lý vớ vẩn kiểu hàng xóm Bắc không chịu thua."
        ),
        NeighborQuote(
            english: "Hmph. One game. Means nothing.",
            vietnamese: "Một ván thôi — bố mày còn cả đời dạy mày.",
            explanationEnglish: "Minimizes the loss, promises future dominance.",
            explanationVietnamese: "Hạ một trận, giữ uy thế lâu dài — 'cả đời dạy'."
        ),
        NeighborQuote(
            english: "You cheated. Probably.",
            vietnamese: "Chắc mày gian rồi — bố tin thế.",
            explanationEnglish: "Accusation without proof — saves face.",
            explanationVietnamese: "Vu khống nhẹ để không mất thể diện trước làng."
        ),
        NeighborQuote(
            english: "I'll remember this.",
            vietnamese: "Bố ghi sổ rồi — lần sau đừng hòng.",
            explanationEnglish: "Threatens a rematch with ominous Northern tone.",
            explanationVietnamese: "'Ghi sổ' — hẹn trả thù, giọng ông hàng xóm Bắc."
        ),
        NeighborQuote(
            english: "Even a broken clock is right twice.",
            vietnamese: "Sao lỗi còn sáng hai lần — mày trúng một bàn.",
            explanationEnglish: "Compares your win to random chance.",
            explanationVietnamese: "Thành ngữ chế: thắng một lần không chứng minh giỏi."
        ),
        NeighborQuote(
            english: "Enjoy it. Won't happen again.",
            vietnamese: "Cười đi — ván sau bố không tha.",
            explanationEnglish: "Bitter promise of revenge.",
            explanationVietnamese: "Đe dọa ván tới — thua miệng nhưng không thua thế."
        ),
        NeighborQuote(
            english: "My cat walked on the board.",
            vietnamese: "Mèo nhà bố chạy qua — coi như bố nhường.",
            explanationEnglish: "Blames a pet — ridiculous but face-saving.",
            explanationVietnamese: "Cớ vật nuôi làm lý do nhường — hài mà cay."
        ),
        NeighborQuote(
            english: "You got me. This once.",
            vietnamese: "Bố mày thừa nhận — một lần. Đừng đắc ý.",
            explanationEnglish: "Rare grudging admission — still lectures you.",
            explanationVietnamese: "Thừa nhận có giới hạn — vẫn xưng bố, vẫn dạy."
        ),
        NeighborQuote(
            english: "Storm's coming. Bad omen for you.",
            vietnamese: "Thắng xong trời sắp mưa — mày coi chừng.",
            explanationEnglish: "Superstitious curse after losing — Northern folk tone.",
            explanationVietnamese: "Gán thắng thua với omens — văn hóa làng Bắc."
        )
    ]

    static func random(language: AppLanguage) -> NeighborQuote {
        all.randomElement() ?? fallback(for: language)
    }

    private static func fallback(for language: AppLanguage) -> NeighborQuote {
        NeighborQuote(
            english: "Hmph.",
            vietnamese: "Hừm… ván này bố nhường.",
            explanationEnglish: "A short grumble — refuses to celebrate with you.",
            explanationVietnamese: "'Nhường' — cách Bắc thua mà vẫn cao ngạo."
        )
    }
}
