import Foundation
import Observation

@Observable
@MainActor
final class NearbyGameController {
    var settings: GameSettings
    private(set) var phase: NearbySessionPhase = .idle
    private(set) var engine: GameEngine
    private(set) var localMark: Mark = .x
    private(set) var discoveredHosts: [DiscoveredHost] = []
    private(set) var isPaused = false
    private(set) var isWinCelebrating = false
    private(set) var gameID = UUID()

    private var service: NearbyGameService?
    private var browseTask: Task<Void, Never>?

    var canAcceptInput: Bool {
        phase == .playing && !isPaused && engine.result == .ongoing && engine.currentPlayer == localMark
    }

    init(settings: GameSettings = .load()) {
        self.settings = settings
        engine = GameEngine(settings: settings)
    }

    func configure(service: NearbyGameService) {
        self.service = service
        service.onMessage = { [weak self] message in
            Task { @MainActor in self?.handle(message: message) }
        }
        service.onConnectionChange = { [weak self] connected in
            Task { @MainActor in self?.handleConnectionChange(connected: connected) }
        }
    }

    func beginSessionIfNeeded() {
        guard settings.mode == .nearbyPvP else {
            cancelSession()
            return
        }
        guard phase == .idle else { return }
        switch settings.nearbyRole {
        case .host:
            startHosting()
        case .join:
            startBrowsing()
        }
    }

    func cancelSession() {
        browseTask?.cancel()
        browseTask = nil
        phase = .idle
        isPaused = false
        isWinCelebrating = false
        discoveredHosts = []
        Task { await service?.stopSession() }
    }

    func join(host: DiscoveredHost) {
        guard let service else { return }
        phase = .connecting
        browseTask?.cancel()
        service.stopBrowsing()
        Task {
            do {
                let participantID = await AppIdentity().currentParticipantID.rawValue
                try await service.join(host: host, participantID: participantID)
                localMark = .o
            } catch {
                phase = .browsing
                startBrowsing()
            }
        }
    }

    func tap(cell: Cell) {
        guard canAcceptInput else { return }
        guard engine.canPlay(at: cell) else { return }

        if service?.isHost == true {
            applyLocalMove(at: cell)
            broadcastState()
        } else {
            Task {
                try? await service?.send(.moveRequest(cell))
            }
        }
    }

    func forfeit() {
        Task {
            try? await service?.send(.forfeit)
            applyRemoteState(NearbyGameState(
                cells: engine.cells,
                currentPlayer: localMark,
                result: .won(localMark),
                winningCells: []
            ))
            checkGameEndCelebration()
        }
    }

    func rematch() {
        guard service?.isHost == true else {
            Task { try? await service?.send(.rematchRequest) }
            return
        }
        resetBoard()
        let invite = GameInvite(
            settings: engine.settings,
            hostParticipantID: service?.localParticipantID ?? ""
        )
        Task {
            try? await service?.send(.rematchAccepted(invite))
            try? await service?.send(.gameState(NearbyGameState(engine: engine)))
        }
    }

    func hostValidateMove(at cell: Cell, by mark: Mark) -> Bool {
        guard engine.result == .ongoing else { return false }
        guard engine.currentPlayer == mark else { return false }
        return engine.canPlay(at: cell)
    }

    func applyRemoteState(_ state: NearbyGameState) {
        engine.apply(state)
    }

    private func startHosting() {
        guard let service else { return }
        phase = .advertising
        Task {
            do {
                let participantID = await AppIdentity().currentParticipantID.rawValue
                localMark = .x
                resetBoard()
                try await service.startHosting(settings: settings, participantID: participantID)
                phase = .playing
            } catch {
                phase = .idle
            }
        }
    }

    private func startBrowsing() {
        guard let service else { return }
        phase = .browsing
        service.startBrowsing()
        browseTask?.cancel()
        browseTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(500))
                guard let self, let service = self.service else { return }
                self.discoveredHosts = service.discoveredHosts
            }
        }
    }

    private func handleConnectionChange(connected: Bool) {
        guard phase == .playing || phase == .paused else { return }
        isPaused = !connected
        phase = connected ? .playing : .paused
    }

    private func handle(message: NearbyGameMessage) {
        switch message {
        case .invite(let invite):
            settings = invite.settings
            engine = GameEngine(settings: invite.settings)
            localMark = .o
        case .moveRequest(let cell):
            guard service?.isHost == true else { return }
            guard hostValidateMove(at: cell, by: localMark.opponent) else { return }
            applyLocalMove(at: cell)
            broadcastState()
        case .gameState(let state):
            applyRemoteState(state)
            if phase == .connecting || phase == .browsing || phase == .advertising {
                phase = .playing
            }
            checkGameEndCelebration()
        case .forfeit:
            applyRemoteState(NearbyGameState(
                cells: engine.cells,
                currentPlayer: localMark,
                result: .won(localMark),
                winningCells: []
            ))
            checkGameEndCelebration()
        case .rematchRequest:
            guard service?.isHost == true else { return }
            rematch()
        case .rematchAccepted(let invite):
            settings = invite.settings
            resetBoard()
            phase = .playing
        }
    }

    private func applyLocalMove(at cell: Cell) {
        guard let result = try? engine.place(at: cell) else { return }
        SoundManager.shared.playPlace()
        if case .won = result {
            checkGameEndCelebration()
        }
    }

    private func broadcastState() {
        Task {
            try? await service?.send(.gameState(NearbyGameState(engine: engine)))
        }
    }

    private func resetBoard() {
        isWinCelebrating = false
        engine = GameEngine(settings: settings)
        gameID = UUID()
    }

    private func checkGameEndCelebration() {
        guard case .won = engine.result else { return }
        isWinCelebrating = true
        Task {
            try? await Task.sleep(for: .seconds(2))
            isWinCelebrating = false
        }
    }
}
