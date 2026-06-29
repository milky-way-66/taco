import SwiftUI

struct SettingsView: View {
    @Bindable var controller: GameController
    @Environment(\.dismiss) private var dismiss
    @State private var draft: GameSettings

    init(controller: GameController) {
        self.controller = controller
        _draft = State(initialValue: controller.settings)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(String(localized: "language_section")) {
                    Picker(String(localized: "language_section"), selection: $draft.language) {
                        ForEach(AppLanguage.allCases) { language in
                            Text(String(localized: String.LocalizationValue(language.settingsLabelKey)))
                                .tag(language)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section(String(localized: "win_length_section")) {
                    Stepper(value: $draft.winLength, in: 3...7) {
                        Text(String(format: String(localized: "win_length_format"), draft.winLength))
                    }
                }
                Section(String(localized: "board_size_section")) {
                    Picker(String(localized: "board_picker_label"), selection: $draft.boardSize) {
                        ForEach(BoardSize.allCases) { size in
                            Text(size.rawValue).tag(size)
                        }
                    }
                }
                Section(String(localized: "mode_section")) {
                    Picker(String(localized: "mode_picker_label"), selection: $draft.mode) {
                        ForEach(GameMode.allCases) { mode in
                            Text(String(localized: String.LocalizationValue(mode.labelKey)))
                                .tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle(String(localized: "settings_title"))
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "done")) {
                        controller.applySettings(draft)
                        dismiss()
                    }
                }
            }
        }
        .environment(\.locale, draft.language.locale)
    }
}
