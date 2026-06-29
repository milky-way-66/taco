import Foundation

enum NeighborQuotes {
  /// Northern Vietnamese "văn hóa chửi" tone — vần điệu, xưng bố, kiểu ông hàng xóm Bắc.
  /// App Store safe: harsh and mocking, no slurs or explicit content.
  static let all: [NeighborQuote] = [
    NeighborQuote(
      english: "My dead dog plays better.",
      vietnamese: "Bố mày bảo cho mày biết: đánh cờ dở thế thì về ấp.",
      explanationEnglish: "Classic Northern 'bố mày' dominance — lecturing you like an elder who owns the truth.",
      explanationVietnamese: "Kiểu 'chủ nghĩa bố đời' miền Bắc: xưng bố, ra lệnh, coi mình cao hơn — theo văn Nguyễn Gia Việt."
    ),
    NeighborQuote(
      english: "You call that thinking?",
      vietnamese: "Mày có óc mà như hòn ma — nhìn mà không thấy đường.",
      explanationEnglish: "Says you have eyes and brain but use neither — a Northern proverb-style jab.",
      explanationVietnamese: "Chế kiểu thành ngữ 'có mắt như hòn ma'; giọng Bắc thích soi trí khôn, hạ người khác."
    ),
    NeighborQuote(
      english: "Back in my day we had brains.",
      vietnamese: "Thời bố mày chơi, chúng mày còn bú sữa.",
      explanationEnglish: "Pulls rank with age — claims your generation is infantile.",
      explanationVietnamese: "Xưng 'bố' + so thời xưa: kiểu trưởng tộc Bắc coi mình là anh cả trong làng."
    ),
    NeighborQuote(
      english: "I've seen fence posts smarter than you.",
      vietnamese: "Cọc rào làng bố còn biết đứng thẳng hơn mày.",
      explanationEnglish: "Even a fence post outperforms you — rural Northern imagery.",
      explanationVietnamese: "Ẩn dụ làng quê Bắc (lũy tre, cọc rào) để chế kẻ vụng về."
    ),
    NeighborQuote(
      english: "Keep practicing. You'll get worse.",
      vietnamese: "Học mãi mà dốt mãi — phí cơm nhà bố.",
      explanationEnglish: "Waste of rice — traditional insult that you're worthless to feed.",
      explanationVietnamese: "'Phí cơm' là lời chửi Bắc xưa: chê không xứng ăn bát cơm nhà."
    ),
    NeighborQuote(
      english: "That move smelled funny. Like you.",
      vietnamese: "Đánh cờ hay đánh bốc bát họ? Bố nghe mà ngán.",
      explanationEnglish: "Compares your play to fortune-telling gibberish.",
      explanationVietnamese: "'Bốc bát họ' — chơi chữ miền Bắc: chê nước đi vô lý như bói toán."
    ),
    NeighborQuote(
      english: "Did your mom teach you that?",
      vietnamese: "Nhà mày dạy mày đánh thế, hay mày tự nghĩ ra?",
      explanationEnglish: "Questions your upbringing — Northern indirect shame on the family.",
      explanationVietnamese: "Chửi kiểu Bắc hay vặn về gia đình, huấn luyện — 'mất dạy' ngầm."
    ),
    NeighborQuote(
      english: "Ha! Kids these days.",
      vietnamese: "Đời trẻ nay, óc để trang trí cho vui thôi.",
      explanationEnglish: "Dismisses youth as decorative, not functional.",
      explanationVietnamese: "Giọng sĩ phu/ông già Bắc chê thế hệ sau kém cỏi, hàn lâm."
    ),
    NeighborQuote(
      english: "You bored me to death.",
      vietnamese: "Xem mày đánh, bố ngán như xem hoa bằng mũi.",
      explanationEnglish: "Paraphrases Nguyễn Khuyến — so dull you could only smell flowers, not see them.",
      explanationVietnamese: "Câu Nguyễn Khuyến: 'Xem hoa ta chỉ xem bằng mũi' — chê nhàm, vô vị."
    ),
    NeighborQuote(
      english: "Even my lawn gnome would win.",
      vietnamese: "Ông nội bố chơi còn khôn hơn mày một bậc.",
      explanationEnglish: "Family elders beat you — lineage as authority.",
      explanationVietnamese: "Kéo tổ tiên, ông bà vào: văn hóa Bắc coi phả hệ là uy quyền."
    ),
    NeighborQuote(
      english: "Try using your head next time.",
      vietnamese: "Bật óc lên, đừng để bố phải chỉ tay năm ngón.",
      explanationEnglish: "'Five fingers pointing' — Northern image of bossy lecturing.",
      explanationVietnamese: "'Chỉ tay năm ngón' — ẩn dụ người Bắc thích ra oai, chỉ bảo kẻ dưới."
    ),
    NeighborQuote(
      english: "Pathetic. Truly pathetic.",
      vietnamese: "Thảm hại! Bố nhìn mà chạnh lòng cho nhà mày.",
      explanationEnglish: "Fake pity for your family — shame by association.",
      explanationVietnamese: "Chửi kiểu 'thâm' Bắc: giả thương để hạ nhục cả họ nhà."
    ),
    NeighborQuote(
      english: "I almost felt sorry. Almost.",
      vietnamese: "Tội cho mày, suýt nữa bố thương — rồi bố nghĩ lại.",
      explanationEnglish: "Withdraws pity — you're not even worth sympathy.",
      explanationVietnamese: "Mỉa mai kiểu Bắc: cho rồi thu, làm người nghe tức âm ỉ."
    ),
    NeighborQuote(
      english: "You play like my arthritic uncle.",
      vietnamese: "Đánh cờ như gà mất gà — lóng ngóng hết cả.",
      explanationEnglish: "Echoes 'lost chicken' folklore panic — clumsy and frantic.",
      explanationVietnamese: "Gợi 'Bà mất gà chửi': chuyện dân gian Bắc, chê loạn, hốt hoảng."
    ),
    NeighborQuote(
      english: "Go back to kindergarten.",
      vietnamese: "Về nhà ăn cơm, đừng ra đây bố mày dạy nữa.",
      explanationEnglish: "Dismisses you home — he's done teaching inferior beings.",
      explanationVietnamese: "'Bố mày dạy' — kiểu ban ơn, cho lời khuyên như thầy trò Bắc xưa."
    ),
    NeighborQuote(
      english: "Was that on purpose? Hope not.",
      vietnamese: "Cố ý hay ngu thật? Bố hỏi cho rõ.",
      explanationEnglish: "Forces you to admit stupidity — rhetorical trap.",
      explanationVietnamese: "Chửi có lớp lang: hỏi để chê, không cho đối thủ cãi."
    ),
    NeighborQuote(
      english: "My garbage plays harder than you.",
      vietnamese: "Rác nhà bố còn biết phân loại hơn mày biết đánh.",
      explanationEnglish: "Trash is more organized than your moves.",
      explanationVietnamese: "So sánh hạ nhục kiểu đô thị Bắc — chê kém cả việc vô tri."
    ),
    NeighborQuote(
      english: "You make losing look easy.",
      vietnamese: "Thua mà ung dung — mất nết nhà mày.",
      explanationEnglish: "Losing without shame insults your family's honor.",
      explanationVietnamese: "Văn hóa Bắc coi 'mất mặt' nặng — chửi cả giáo dục gia đình."
    ),
    NeighborQuote(
      english: "I've had better naps than this game.",
      vietnamese: "Ngủ trưa còn kịch tính hơn coi mày đánh.",
      explanationEnglish: "Sleep beats watching you — ultimate boredom insult.",
      explanationVietnamese: "Chê nhàm theo nhịp đời Bắc: trưa ngủ, chiều rảnh — mày phí thời gian."
    ),
    NeighborQuote(
      english: "Stick to hopscotch, kid.",
      vietnamese: "Mày chơi ô ăn quan đi, đừng cờ với bố.",
      explanationEnglish: "Children's sidewalk games suit you — not this.",
      explanationVietnamese: "'Ô ăn quan' — trò làng xưa miền Bắc; chê trẻ con, chưa đủ trình."
    ),
    NeighborQuote(
      english: "Skill issue. Always has been.",
      vietnamese: "Bố mày cho mày thua cho biết thân biết phận.",
      explanationEnglish: "'Bố mày cho' — grants defeat as a lesson in hierarchy.",
      explanationVietnamese: "Cú chốt kiểu 'ban phát' — chủ nghĩa bố đời: thua là ân huệ từ trên xuống."
    ),
    NeighborQuote(
      english: "Brain diff, honestly.",
      vietnamese: "Óc mày với óc bố — cách một trời một vực.",
      explanationEnglish: "Heaven and earth apart — classical distance metaphor.",
      explanationVietnamese: "'Một trời một vực' — thành ngữ Bắc nhấn khoảng cách trí tuệ."
    ),
    NeighborQuote(
      english: "Clown behavior. Real circus stuff.",
      vietnamese: "Hôm nay bố chửi một bài, ngày mai bố chửi hai lần liền.",
      explanationEnglish: "Paraphrases the 'lost chicken' curse rhythm — promises more scolding.",
      explanationVietnamese: "Vần điệu từ 'Bà mất gà chửi': chửi liên miên, có nhịp — đặc sản Bắc."
    ),
    NeighborQuote(
      english: "Thought you were good. Cute.",
      vietnamese: "Tưởng thầy ai dè ra học trò — mày về vai phụ đi.",
      explanationEnglish: "Northern proverb — thought you were the master, you're the pupil.",
      explanationVietnamese: "'Tưởng thầy ra học trò' — thành ngữ chê kẻ tự cao bị bẻ lái."
    ),
    NeighborQuote(
      english: "Lag? Nah. Just bad.",
      vietnamese: "Đừng đổ lỗi trời đất — mày dốt thì dốt.",
      explanationEnglish: "No excuses — Northern blunt moral verdict.",
      explanationVietnamese: "Giọng Bắc thẳng, ít vòng vo: chê bản thân, không chấp hoàn cảnh."
    ),
    NeighborQuote(
      english: "Cope harder, champ.",
      vietnamese: "Cay thì cay, bố mày thắng rồi — nghe cho hết.",
      explanationEnglish: "Rubbing salt — savor your bitterness.",
      explanationVietnamese: "Chửi thâm: bắt đối thủ nuốt đắng, không cho phản kháng."
    ),
    NeighborQuote(
      english: "Touch grass. Then maybe learn.",
      vietnamese: "Về lo cơm nước đi, đừng phí thì giờ bố mày.",
      explanationEnglish: "From 'lost chicken' monologue — go live your life, stop wasting mine.",
      explanationVietnamese: "Trích tinh thần 'Bà mất gà': 'tao vào lo cơm nước' — đuổi kẻ vô dụng."
    ),
    NeighborQuote(
      english: "Hard to watch. Harder to lose to.",
      vietnamese: "Nhìn mày đánh, bố tủi cho cái đầu nhà mày.",
      explanationEnglish: "Pity your family's head — shame on your ancestors.",
      explanationVietnamese: "Chửi lan sang tổ tiên — kiểu Bắc đào sâu vào phả hệ để hạ."
    ),
    NeighborQuote(
      english: "Built different. Bad different.",
      vietnamese: "Người ta chơi cờ, mày chơi mặt — khác hẳn.",
      explanationEnglish: "'Play face not chess' — Northern idiom for shameless bad play.",
      explanationVietnamese: "'Chơi mặt' — chê không biết xấu hổ, đánh ẩu mà cứ ra vẻ."
    ),
    NeighborQuote(
      english: "Don't make me laugh. Oh wait, you did.",
      vietnamese: "Phụt! Chẳng phải đứa tiểu tâm — đùng tiếng lói sau nhà!",
      explanationEnglish: "Echoes Nguyễn Du's curse verse — petty ghost making noise.",
      explanationVietnamese: "Nguyễn Du, Văn tế Trường Lưu: chửi văn chương, giọng Bắc lên bổng xuống trầm."
    )
  ]

  static func random(language: AppLanguage) -> NeighborQuote {
    all.randomElement() ?? fallback(for: language)
  }

  private static func fallback(for language: AppLanguage) -> NeighborQuote {
    NeighborQuote(
      english: "Ha!",
      vietnamese: "Ấy ấy… bố mày chưa chửi hết đấy.",
      explanationEnglish: "A short Northern scoff — more insults loading.",
      explanationVietnamese: "'Ấy ấy' — lối dẫn vần điệu chửi Bắc, như khúc trong 'Bà mất gà chửi'."
    )
  }
}
