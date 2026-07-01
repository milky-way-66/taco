import ComunicationCore
import Foundation
import UIKit

@MainActor
final class NearbyGameService {
    private let transferService: TransferService
    private let peerBrowser: NearbyPeerBrowser
    private var channelID: UUID?
    private var messageTask: Task<Void, Never>?
    private var connectionTask: Task<Void, Never>?
    var onMessage: ((NearbyGameMessage) -> Void)?
    var onConnectionChange: ((Bool) -> Void)?

    private(set) var isHost = false
    private(set) var localParticipantID: String = ""

    init(transferService: TransferService) {
        self.transferService = transferService
        peerBrowser = NearbyPeerBrowser(serviceType: TransferService.serviceType)
    }

    var discoveredHosts: [DiscoveredHost] {
        peerBrowser.hosts
    }

    func startBrowsing() {
        peerBrowser.start()
    }

    func stopBrowsing() {
        peerBrowser.stop()
    }

    func startHosting(settings: GameSettings, participantID: String) async throws {
        isHost = true
        localParticipantID = participantID
        stopBrowsing()

        let discoveryInfo = [
            "participantID": participantID,
            "boardSize": settings.boardSize.rawValue,
            "winLength": "\(settings.winLength)"
        ]
        transferService.configureMPC(discoveryInfo: discoveryInfo)
        try await transferService.start()

        let channel = try await transferService.engine.createChannel(
            title: "TacXO PvP",
            participants: [
                Participant(id: ParticipantID(participantID), displayName: UIDevice.current.name)
            ]
        )
        channelID = channel.id
        observeMessages(for: channel.id)
        observeConnection(for: channel.id)

        let invite = GameInvite(
            settings: hostingSettings(from: settings),
            hostParticipantID: participantID
        )
        try await waitForPeer(on: channel.id)
        try await send(.invite(invite))
        try await send(.gameState(NearbyGameState(
            cells: [:],
            currentPlayer: .x,
            result: .ongoing,
            winningCells: []
        )))
    }

    func join(host: DiscoveredHost, participantID: String) async throws {
        isHost = false
        localParticipantID = participantID
        stopBrowsing()

        transferService.configureMPC(discoveryInfo: ["participantID": participantID])
        try await transferService.start()

        let channel = try await transferService.engine.createChannel(
            title: "TacXO PvP",
            participants: [
                Participant(id: ParticipantID(participantID), displayName: UIDevice.current.name),
                Participant(id: ParticipantID(host.id), displayName: host.displayName)
            ]
        )
        channelID = channel.id
        observeMessages(for: channel.id)
        observeConnection(for: channel.id)
        try await waitForPeer(on: channel.id)
    }

    func send(_ message: NearbyGameMessage) async throws {
        guard let channelID else { return }
        try await transferService.engine.send(message, in: channelID)
    }

    func stopSession() async {
        messageTask?.cancel()
        connectionTask?.cancel()
        messageTask = nil
        connectionTask = nil
        stopBrowsing()
        channelID = nil
        isHost = false
        await transferService.stop()
    }

    private func hostingSettings(from settings: GameSettings) -> GameSettings {
        var hosted = settings
        hosted.mode = .nearbyPvP
        return hosted
    }

    private func waitForPeer(on channelID: UUID) async throws {
        for _ in 0..<80 {
            try Task.checkCancellation()
            if await transferService.isPeerConnected(for: channelID) { return }
            try await Task.sleep(for: .milliseconds(250))
        }
        throw CommunicationError.transportFailed("Timed out waiting for opponent")
    }

    private func observeMessages(for channelID: UUID) {
        messageTask?.cancel()
        messageTask = Task { [weak self] in
            guard let self else { return }
            for await items in transferService.engine.itemUpdates(for: channelID) {
                guard !Task.isCancelled else { return }
                for item in items {
                    guard let message = Self.decodeMessage(from: item) else { continue }
                    onMessage?(message)
                }
            }
        }
    }

    private func observeConnection(for channelID: UUID) {
        connectionTask?.cancel()
        var lastConnected: Bool?
        connectionTask = Task { [weak self] in
            guard let self else { return }
            while !Task.isCancelled {
                let connected = await transferService.isPeerConnected(for: channelID)
                if lastConnected != connected {
                    lastConnected = connected
                    onConnectionChange?(connected)
                }
                try? await Task.sleep(for: .milliseconds(500))
            }
        }
    }

    private static func decodeMessage(from item: TransferItem) -> NearbyGameMessage? {
        switch item.payload {
        case .json(let data):
            return try? JSONDecoder().decode(NearbyGameMessage.self, from: data)
        default:
            return nil
        }
    }
}
