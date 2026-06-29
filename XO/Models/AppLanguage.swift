import Foundation

enum AppLanguage: String, Codable, CaseIterable, Identifiable {
    case system
    case english = "en"
    case vietnamese = "vi"

    var id: String { rawValue }

    var locale: Locale {
        switch self {
        case .system:
            return .autoupdatingCurrent
        case .english:
            return Locale(identifier: "en")
        case .vietnamese:
            return Locale(identifier: "vi")
        }
    }

    /// Resolved language for quotes and non-catalog strings.
    var effectiveLanguageCode: String {
        switch self {
        case .system:
            let code = Locale.current.language.languageCode?.identifier ?? "en"
            return code == "vi" ? "vi" : "en"
        case .english:
            return "en"
        case .vietnamese:
            return "vi"
        }
    }

    var settingsLabelKey: String {
        switch self {
        case .system: return "language_system"
        case .english: return "language_english"
        case .vietnamese: return "language_vietnamese"
        }
    }
}
