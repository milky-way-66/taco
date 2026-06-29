import SwiftUI

struct PlayView: View {
    @Bindable var controller: GameController
    @State private var showSettings = false
    @State private var boardOpacity = 1.0
    @State private var boardScale = 1.0
    @State private var refreshRotation = 0.0
    @State private var isResettingBoard = false

    var body: some View {
        ZStack {
            GameBackgroundView()

            VStack(spacing: 0) {
                topBar

                ZStack(alignment: .top) {
                    BoardView(
                        engine: controller.engine,
                        isInteractive: controller.engine.result == .ongoing
                            && !isResettingBoard
                            && !controller.isAIThinking
                    ) { cell in
                        controller.tap(cell: cell)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .scaleEffect(boardScale)
                    .opacity(boardOpacity)
                    .blur(radius: boardOpacity < 0.98 ? (1 - boardOpacity) * 3 : 0)
                    .id(controller.gameID)

                    if controller.settings.mode == .vsNeighbor,
                       let comment = controller.neighborComment {
                        NeighborSpeechBubbleView(
                            name: Neighbor.name(for: controller.settings.language),
                            text: comment.text,
                            mood: comment.mood
                        )
                        .id(comment)
                        .padding(.horizontal, 16)
                        .padding(.top, 10)
                        .transition(
                            .asymmetric(
                                insertion: .identity,
                                removal: .opacity.combined(with: .offset(y: -28))
                            )
                        )
                        .zIndex(2)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

            if controller.isWinCelebrating {
                WinCelebrationView(winStreak: controller.difficulty.winStreak)
                    .transition(.opacity)
                    .zIndex(0.5)
            }

            if let overlay = controller.quoteOverlay {
                QuoteOverlayView(
                    quote: overlay.quote,
                    kind: overlay.kind,
                    language: controller.settings.language,
                    hardnessPercent: overlay.hardnessPercent,
                    hardnessDelta: overlay.hardnessDelta,
                    winStreak: overlay.winStreak,
                    onDismiss: { startNewGame() }
                )
                .transition(.opacity.combined(with: .move(edge: .bottom)))
                .zIndex(1)
            }
        }
        .animation(GameTheme.commentSpring, value: controller.neighborComment)
        .animation(GameTheme.overlaySpring, value: controller.quoteOverlay != nil)
        .sheet(isPresented: $showSettings) {
            SettingsView(controller: controller)
        }
    }

    private var topBar: some View {
        HStack(spacing: 12) {
            Button {
                showSettings = true
            } label: {
                Image(systemName: "gearshape")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .frame(width: 44, height: 44)

            Text(statusLabel)
                .contentTransition(.numericText())
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.85)
                .animation(GameTheme.newGameSpring, value: statusLabel)

            if controller.settings.mode == .vsNeighbor {
                hardnessBadge
            }

            Button {
                startNewGame()
            } label: {
                Image(systemName: "arrow.counterclockwise")
                    .font(.body)
                    .foregroundStyle(.tint)
                    .rotationEffect(.degrees(refreshRotation))
            }
            .buttonStyle(.plain)
            .frame(width: 44, height: 44)
            .accessibilityLabel(String(localized: "new_game"))
            .disabled(isResettingBoard)
        }
        .padding(.horizontal, 12)
        .padding(.bottom, 8)
        .background(GameTheme.backgroundTop)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.primary.opacity(0.06))
                .frame(height: 0.5)
        }
    }

    private var hardnessBadge: some View {
        HardnessNavBadge(
            percent: controller.difficulty.hardnessPercent,
            winStreak: controller.difficulty.winStreak
        )
    }

    private func startNewGame() {
        guard !isResettingBoard else { return }

        isResettingBoard = true
        withAnimation(.easeInOut(duration: 0.38)) {
            refreshRotation += 360
        }
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()

        withAnimation(GameTheme.newGameExit) {
            controller.dismissQuoteOverlay()
            boardOpacity = 0
            boardScale = 0.9
        }

        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(260))
            controller.newGame()
            boardScale = 1.05

            withAnimation(GameTheme.newGameSpring) {
                boardOpacity = 1
                boardScale = 1
            }

            try? await Task.sleep(for: .milliseconds(420))
            isResettingBoard = false
        }
    }

    private var statusLabel: String {
        switch controller.engine.result {
        case .ongoing:
            if controller.settings.mode == .vsNeighbor, controller.engine.currentPlayer == .o {
                return String(localized: "neighbor_turn")
            }
            return String(
                format: String(localized: "turn_of_player"),
                controller.engine.currentPlayer.label
            )
        case .won(let mark):
            if controller.settings.mode == .vsNeighbor, mark == .o {
                return String(localized: "neighbor_wins")
            }
            return String(format: String(localized: "player_wins"), mark.label)
        case .draw:
            return String(localized: "draw_flavor")
        }
    }
}
