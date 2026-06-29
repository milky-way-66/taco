import Foundation

enum NeighborWinQuotes {
  /// Ông Sáu when the player beats him — denial, excuses, grudging respect.
  static let all: [NeighborQuote] = [
    NeighborQuote(
      english: "Lucky. Pure luck.",
      vietnamese: "May mắn vớ vẩn thôi! Bố bố thí cho mày thắng một ván.",
    ),
    NeighborQuote(
      english: "The board was crooked.",
      vietnamese: "Bàn cờ này bị lệch — bố không chấp.",
    ),
    NeighborQuote(
      english: "I wasn't even trying.",
      vietnamese: "Bố chơi cho vui thôi, chưa nghiêm túc gì đâu.",
    ),
    NeighborQuote(
      english: "Beginner's luck, that's all.",
      vietnamese: "May tạm thời thôi — đừng tưởng bở mà hết nước cờ.",
    ),
    NeighborQuote(
      english: "My hand slipped. Twice.",
      vietnamese: "Tay bố đang đau nhức — mày thắng kiểu gì cũng được.",
    ),
    NeighborQuote(
      english: "Fine. You win. Happy now?",
      vietnamese: "Thắng rồi thì thắng — đừng có mặt dày mà vênh váo.",
    ),
    NeighborQuote(
      english: "The sun was in my eyes.",
      vietnamese: "Nắng chói quá — ván sau bố tính sổ mày.",
    ),
    NeighborQuote(
      english: "Hmph. One game. Means nothing.",
      vietnamese: "Được một ván thôi — bố còn cả đời để dạy dỗ mày.",
    ),
    NeighborQuote(
      english: "You cheated. Probably.",
      vietnamese: "Chắc chắn là gian lận rồi — bố tin là thế.",
    ),
    NeighborQuote(
      english: "I'll remember this.",
      vietnamese: "Bố ghi vào sổ đen — lần sau đừng hòng thoát.",
    ),
    NeighborQuote(
      english: "Even a broken clock is right twice.",
      vietnamese: "Gà mù đụng trúng — mày trúng một bàn, đừng tưởng bở.",
    ),
    NeighborQuote(
      english: "Enjoy it. Won't happen again.",
      vietnamese: "Cười đi — ván sau bố không buông tha mày đâu.",
    ),
    NeighborQuote(
      english: "My cat walked on the board.",
      vietnamese: "Con mèo chạy qua bàn — coi như bố nhường đường.",
    ),
    NeighborQuote(
      english: "You got me. This once.",
      vietnamese: "Bố thừa nhận — một lần duy nhất thôi. Đừng có mà đắc ý.",
    ),
    NeighborQuote(
      english: "Storm's coming. Bad omen for you.",
      vietnamese: "Thắng xong trời sắp mưa bão — coi chừng đấy.",
    ),
    NeighborQuote(
      english: "Even the broken clock… you got lucky once.",
      vietnamese: "Có thời ván đen ăn ván đỏ — hôm nay mày ăn may, mai trả lại.",
    ),
    NeighborQuote(
      english: "Lose today, win tomorrow — not for you.",
      vietnamese: "Thua keo này bày keo khác — keo sau bố không cho mày bày.",
    ),
    NeighborQuote(
      english: "Heaven helps those who help themselves — barely you.",
      vietnamese: "Trời sinh voi sinh cỏ — mày ăn may một phen, đừng tưởng mình voi.",
    ),
    NeighborQuote(
      english: "One swallow doesn't make spring.",
      vietnamese: "Một con én không làm nên mùa xuân — thắng một ván chẳng làm nên cao thủ.",
    ),
    NeighborQuote(
      english: "The river flows, the rock stays — I'm the rock.",
      vietnamese: "Nước chảy, đá mòn — mày chảy qua, bố vẫn đứng.",
    ),
    NeighborQuote(
      english: "Borrowed clothes never fit — borrowed luck too.",
      vietnamese: "Ăn miếng trả miếng — may mượn một ván, trả bố ván sau.",
    ),
    NeighborQuote(
      english: "Good wood, bad paint — good luck, bad player.",
      vietnamese: "Tốt gỗ hơn tốt nước sơn — mày may một lần, dở cả đời.",
    ),
    NeighborQuote(
      english: "The moon has phases — so does my mercy. Not today.",
      vietnamese: "Trăng khuyết rồi lại tròn — lần sau bố không nhường đâu.",
    ),
    NeighborQuote(
      english: "Fortune favors fools sometimes.",
      vietnamese: "Cười người hôm trước, hôm sau người cười — hôm nay mày cười, mai khóc.",
    ),
    NeighborQuote(
      english: "Rice falls to the lucky — not skill.",
      vietnamese: "Gạo rơi thì gà ăn — mày ăn may chứ giỏi gì.",
    ),
    NeighborQuote(
      english: "Ants pile up over time.",
      vietnamese: "Kiến tha lâu cũng đầy tổ — mày thắng một lần, bố nhớ mãi.",
    ),
    NeighborQuote(
      english: "Walk at night, meet trouble.",
      vietnamese: "Đi đêm có ngày gặp ma — thắng bố một lần, coi chừng.",
    ),
    NeighborQuote(
      english: "Empty belly, empty head.",
      vietnamese: "Ăn không no, cày không sâu — mày thắng may, óc vẫn nông.",
    ),
    NeighborQuote(
      english: "One game doesn't make a master.",
      vietnamese: "Học ăn, học nói, học gói, học mở — mày mới học thắng một bài.",
    ),
    NeighborQuote(
      english: "Luck runs out like water.",
      vietnamese: "Nước đến chân mới nhảy — may đến đầu mày mới biết đỡ.",
    ),
  ]

  static func random(language: AppLanguage) -> NeighborQuote {
    all.randomElement() ?? fallback(for: language)
  }

  private static func fallback(for language: AppLanguage) -> NeighborQuote {
    NeighborQuote(
      english: "Hmph.",
      vietnamese: "Hừm… ván này bố nhường cho vui vậy.",
    )
  }
}
