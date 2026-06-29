import Foundation

struct NeighborQuote: Equatable {
    let english: String
    let vietnamese: String
    let explanationEnglish: String
    let explanationVietnamese: String

    func text(for language: AppLanguage) -> String {
        language.effectiveLanguageCode == "vi" ? vietnamese : english
    }
}
