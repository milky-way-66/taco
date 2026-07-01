import SwiftUI

struct SettingsView: View {
    @Bindable var controller: GameController
    @Bindable var nearbyController: NearbyGameController
    @Environment(\.dismiss) private var dismiss
    @State private var draft: GameSettings

    init(controller: GameController, nearbyController: NearbyGameController) {
        self.controller = controller
        self.nearbyController = nearbyController
        _draft = State(initialValue: controller.settings)
    }

    private var isNearbyJoin: Bool {
        draft.mode == .nearbyPvP && draft.nearbyRole == .join
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

                if !isNearbyJoin {
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

                if draft.mode == .nearbyPvP {
                    Section(String(localized: "nearby_role_section")) {
                        Picker(String(localized: "nearby_role_section"), selection: $draft.nearbyRole) {
                            ForEach(NearbyRole.allCases) { role in
                                Text(String(localized: String.LocalizationValue(role.labelKey)))
                                    .tag(role)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                }
            }
            .navigationTitle(String(localized: "settings_title"))
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "done")) {
                        applyDraft()
                        dismiss()
                    }
                }
            }
        }
        .environment(\.locale, draft.language.locale)
    }

    private func applyDraft() {
        draft.save()
        controller.settings.mode = draft.mode
        controller.settings.language = draft.language
        controller.settings.nearbyRole = draft.nearbyRole
        if draft.mode == .nearbyPvP {
            nearbyController.cancelSession()
            nearbyController.settings = draft
            nearbyController.beginSessionIfNeeded()
        } else {
            nearbyController.cancelSession()
            controller.applySettings(draft)
        }
    }
}
