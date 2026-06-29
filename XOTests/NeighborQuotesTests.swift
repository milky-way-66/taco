import XCTest
@testable import XO

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
        for _ in 0..<60 {
            quotes.insert(NeighborQuotes.random(language: .english).english)
        }
        XCTAssertTrue(quotes.contains(where: { $0.contains("dog") || $0.contains("thinking") }))
    }

    func testEachQuoteHasBilingualExplanations() {
        for quote in NeighborQuotes.all {
            XCTAssertFalse(quote.explanationEnglish.isEmpty)
            XCTAssertFalse(quote.explanationVietnamese.isEmpty)
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
