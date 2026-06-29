import Foundation

/// Ông Sáu — the grumpy Northern Vietnamese neighbor over the fence.
enum Neighbor {
    static func name(for language: AppLanguage) -> String {
        String(localized: "neighbor_name", locale: language.locale)
    }
}
