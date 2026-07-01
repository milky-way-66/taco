import ComunicationCore
import ComunicationMPC
import Foundation
import UIKit

@MainActor
final class TransferService {
    static let serviceType = "tacxo-pvp"

    let engine: CommunicationEngine
    private(set) var mpcTransport: MPCTransportAdapter?
    private var isStarted = false

    init() throws {
        engine = try CommunicationEngine(
            configuration: .init(mpcDiscoveryTimeout: 8),
            identity: AppIdentity()
        )
    }

    func configureMPC(discoveryInfo: [String: String]) {
        guard mpcTransport == nil else { return }
        let adapter = MPCTransportAdapter(
            serviceType: Self.serviceType,
            displayName: UIDevice.current.name,
            discoveryInfo: discoveryInfo
        )
        mpcTransport = adapter
        engine.register(transport: adapter)
    }

    func start() async throws {
        guard !isStarted else { return }
        try await engine.start()
        isStarted = true
    }

    func stop() async {
        guard isStarted else { return }
        await engine.stop()
        isStarted = false
    }

    func isPeerConnected(for channelID: UUID) async -> Bool {
        guard let mpcTransport,
              let channel = try? await engine.channels().first(where: { $0.id == channelID }) else {
            return false
        }
        let ref = ChannelRef(
            channelID: channel.id,
            mpcSessionID: channel.mpcSessionID,
            cloudKitRef: channel.cloudKitRef
        )
        return await mpcTransport.isPeerConnected(for: ref)
    }
}
