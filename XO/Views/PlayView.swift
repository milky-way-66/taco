import SwiftUI

struct PlayView: View {
    @Bindable var controller: GameController
    @State private var showSettings = false

    var body: some View {
        ZStack {
            PaperBackgroundView()

            VStack(spacing: 16) {
                HStack {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                            .font(.title2)
                    }
                    Spacer()
                    Text(turnLabel)
                        .font(.system(.headline, design: .serif))
                }
                .padding(.horizontal)

                BoardView(engine: controller.engine) { cell in
                    controller.tap(cell: cell)
                }

                if controller.engine.result != .ongoing {
                    Text(gameOverLabel)
                        .font(.system(.title3, design: .serif))
                }

                Button(String(localized: "new_game")) {
                    controller.newGame()
                }
                .font(.system(.body, design: .serif))
                .padding(.bottom)
            }

            if controller.showLossOverlay, let quote = controller.lossQuote {
                LossOverlayView(quote: quote, language: controller.settings.language)
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(controller: controller)
        }
    }

    private var turnLabel: String {
        switch controller.engine.result {
        case .ongoing:
            return String(
                format: String(localized: "turn_of_player"),
                controller.engine.currentPlayer.label
            )
        case .won(let mark):
            return String(format: String(localized: "player_wins"), mark.label)
        case .draw:
            return String(localized: "draw")
        }
    }

    private var gameOverLabel: String {
        switch controller.engine.result {
        case .won(let mark):
            return String(format: String(localized: "player_wins"), mark.label)
        case .draw:
            return String(localized: "draw_flavor")
        case .ongoing:
            return ""
        }
    }
}
