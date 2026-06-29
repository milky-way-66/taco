import XCTest
@testable import TacXO

final class NeighborQuotesTests: XCTestCase {
    func testVietnameseQuotesUseNorthernTraditionalTone() {
        var quotes = Set<String>()
        for _ in 0..<60 {
            quotes.insert(NeighborQuotes.random(language: .vietnamese).vietnamese)
        }
        XCTAssertTrue(quotes.contains(where: { $0.contains("bố") || $0.contains("Bố") }))
        XCTAssertFalse(quotes.contains("Gà quá, gà vãi."))
        XCTAssertGreaterThan(quotes.count, 10)
    }

    func testEnglishQuotesUseEnglishPool() {
        var quotes = Set<String>()
        for _ in 0..<120 {
            quotes.insert(NeighborQuotes.random(language: .english).english)
        }
        let proverbMarkers = ["dog", "thinking", "lose", "heaven", "luck", "win"]
        XCTAssertTrue(quotes.contains(where: { quote in
            proverbMarkers.contains(where: { quote.localizedCaseInsensitiveContains($0) })
        }))
    }

    func testEachWinQuoteHasBilingualText() {
        for quote in NeighborWinQuotes.all {
            XCTAssertFalse(quote.english.isEmpty)
            XCTAssertFalse(quote.vietnamese.isEmpty)
        }
    }

    func testEachLossQuoteHasBilingualText() {
        for quote in NeighborQuotes.all {
            XCTAssertFalse(quote.english.isEmpty)
            XCTAssertFalse(quote.vietnamese.isEmpty)
        }
    }

    func testTextSelectionByLanguage() {
        let quote = NeighborQuotes.all[0]
        XCTAssertEqual(quote.text(for: .english), quote.english)
        XCTAssertEqual(quote.text(for: .vietnamese), quote.vietnamese)
    }

    func testEffectiveLanguageCodeIsStable() {
        XCTAssertEqual(AppLanguage.english.effectiveLanguageCode, "en")
        XCTAssertEqual(AppLanguage.vietnamese.effectiveLanguageCode, "vi")
    }
}
