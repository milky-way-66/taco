import SwiftUI

struct PlayView: View {
    @Bindable var controller: GameController
    @Bindable var nearbyController: NearbyGameController
    @State private var showSettings = false
    @State private var boardOpacity = 1.0
    @State private var boardScale = 1.0
    @State private var refreshRotation = 0.0
    @State private var isResettingBoard = false

    private var isNearbyMode: Bool {
        controller.settings.mode == .nearbyPvP
    }

    private var activeEngine: GameEngine {
        isNearbyMode ? nearbyController.engine : controller.engine
    }

    var body: some View {
        ZStack {
            GameBackgroundView()

            VStack(spacing: 0) {
                topBar

                ZStack(alignment: .top) {
                    mainContent
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                    if !isNearbyMode,
                       controller.settings.mode == .vsNeighbor,
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
            }

            if isNearbyMode, nearbyController.isPaused {
                NearbyPauseOverlay(onForfeit: { nearbyController.forfeit() })
                    .zIndex(3)
            }

            if isNearbyMode ? nearbyController.isWinCelebrating : controller.isWinCelebrating {
                WinCelebrationView(winStreak: isNearbyMode ? 0 : controller.difficulty.winStreak)
                    .transition(.opacity)
                    .zIndex(0.5)
            }

            if !isNearbyMode, let overlay = controller.quoteOverlay {
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
            SettingsView(controller: controller, nearbyController: nearbyController)
        }
        .onAppear {
            syncNearbySettingsFromController()
        }
    }

    @ViewBuilder
    private var mainContent: some View {
        if isNearbyMode {
            switch nearbyController.phase {
            case .idle, .advertising:
                if nearbyController.settings.nearbyRole == .host {
                    NearbyHostLobbyView(
                        settings: nearbyController.settings,
                        isWaiting: nearbyController.phase == .advertising,
                        onHost: { nearbyController.beginSessionIfNeeded() },
                        onCancel: { nearbyController.cancelHosting() }
                    )
                } else {
                    NearbyBrowseView(
                        hosts: nearbyController.discoveredHosts,
                        onJoin: { host in nearbyController.join(host: host) },
                        onRefresh: { nearbyController.refreshBrowsing() }
                    )
                }
            case .browsing:
                NearbyBrowseView(
                    hosts: nearbyController.discoveredHosts,
                    onJoin: { host in nearbyController.join(host: host) },
                    onRefresh: { nearbyController.refreshBrowsing() }
                )
            case .connecting:
                VStack(spacing: 24) {
                    Spacer()
                    ProgressView(String(localized: "nearby_connecting"))
                    Spacer()
                    Button(String(localized: "nearby_cancel"), role: .cancel) {
                        nearbyController.cancelConnecting()
                    }
                    .buttonStyle(.bordered)
                    .padding(.bottom, 24)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .playing, .paused:
                nearbyBoardContent
            }
        } else {
            localBoardContent
        }
    }

    private var localBoardContent: some View {
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
        .scaleEffect(boardScale)
        .opacity(boardOpacity)
        .blur(radius: boardOpacity < 0.98 ? (1 - boardOpacity) * 3 : 0)
        .id(controller.gameID)
    }

    private var nearbyBoardContent: some View {
        BoardView(
            engine: nearbyController.engine,
            isInteractive: nearbyController.canAcceptInput && !isResettingBoard
        ) { cell in
            nearbyController.tap(cell: cell)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .scaleEffect(boardScale)
        .opacity(boardOpacity)
        .id(nearbyController.gameID)
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

            if showsNewGameButton {
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
            } else {
                Color.clear.frame(width: 44, height: 44)
            }
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

    private var showsNewGameButton: Bool {
        if isNearbyMode {
            return nearbyController.phase == .playing || nearbyController.phase == .paused
        }
        return true
    }

    private var hardnessBadge: some View {
        HardnessNavBadge(
            percent: controller.difficulty.hardnessPercent,
            winStreak: controller.difficulty.winStreak
        )
    }

    private func syncNearbySettingsFromController() {
        if controller.settings.mode == .nearbyPvP {
            nearbyController.settings = controller.settings
        }
    }

    private func startNewGame() {
        guard !isResettingBoard else { return }

        if isNearbyMode {
            nearbyController.rematch()
            return
        }

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
        if isNearbyMode {
            return nearbyStatusLabel
        }
        return localStatusLabel
    }

    private var nearbyStatusLabel: String {
        switch nearbyController.phase {
        case .idle:
            return nearbyController.settings.nearbyRole == .host
                ? String(localized: "nearby_host_ready")
                : String(localized: "nearby_browse_title")
        case .advertising:
            return String(localized: "nearby_waiting")
        case .browsing:
            return String(localized: "nearby_browse_title")
        case .connecting:
            return String(localized: "nearby_connecting")
        case .playing, .paused:
            return nearbyGameStatusLabel
        }
    }

    private var nearbyGameStatusLabel: String {
        switch nearbyController.engine.result {
        case .ongoing:
            if nearbyController.engine.currentPlayer == nearbyController.localMark {
                return String(localized: "nearby_your_turn")
            }
            return String(localized: "nearby_opponent_turn")
        case .won(let mark):
            if mark == nearbyController.localMark {
                return String(localized: "nearby_you_win")
            }
            return String(localized: "nearby_opponent_wins")
        case .draw:
            return String(localized: "draw_flavor")
        }
    }

    private var localStatusLabel: String {
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
