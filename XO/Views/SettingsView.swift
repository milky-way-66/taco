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
                Section("Win Length") {
                    Stepper(value: $draft.winLength, in: 3...7) {
                        Text("\(draft.winLength) in a row")
                    }
                }
                Section("Board Size") {
                    Picker("Board", selection: $draft.boardSize) {
                        ForEach(BoardSize.allCases) { size in
                            Text(size.rawValue).tag(size)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                Section("Mode") {
                    Picker("Mode", selection: $draft.mode) {
                        ForEach(GameMode.allCases) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        controller.applySettings(draft)
                        dismiss()
                    }
                }
            }
        }
    }
}
