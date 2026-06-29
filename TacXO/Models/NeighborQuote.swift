import Foundation

struct NeighborQuote: Equatable {
    let english: String
    let vietnamese: String

    func text(for language: AppLanguage) -> String {
        language.effectiveLanguageCode == "vi" ? vietnamese : english
    }
}
