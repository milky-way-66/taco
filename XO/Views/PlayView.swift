import SwiftUI

struct PlayView: View {
    @Bindable var controller: GameController
    @State private var showSettings = false

    var body: some View {
        ZStack {
            Color(red: 0.98, green: 0.96, blue: 0.9)
                .ignoresSafeArea()

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

                Button("New Game") {
                    controller.newGame()
                }
                .font(.system(.body, design: .serif))
                .padding(.bottom)
            }

            if controller.showLossOverlay, let quote = controller.lossQuote {
                LossOverlayView(quote: quote)
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(controller: controller)
        }
    }

    private var turnLabel: String {
        switch controller.engine.result {
        case .ongoing:
            return "\(controller.engine.currentPlayer.label)'s turn"
        case .won(let mark):
            return "\(mark.label) wins!"
        case .draw:
            return "Draw"
        }
    }

    private var gameOverLabel: String {
        switch controller.engine.result {
        case .won(let mark): return "\(mark.label) wins!"
        case .draw: return "Draw — even garbage ties sometimes."
        case .ongoing: return ""
        }
    }
}
