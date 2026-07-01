import Foundation
import MultipeerConnectivity
import UIKit

struct DiscoveredHost: Identifiable, Equatable {
    let id: String
    let displayName: String
    let boardSize: BoardSize
    let winLength: Int
}

@MainActor
final class NearbyPeerBrowser: NSObject, ObservableObject {
    @Published private(set) var hosts: [DiscoveredHost] = []

    private let serviceType: String
    private var browser: MCNearbyServiceBrowser?
    private var peerNames: [String: String] = [:]

    init(serviceType: String) {
        self.serviceType = serviceType
        super.init()
    }

    func start() {
        stop()
        let browser = MCNearbyServiceBrowser(
            peer: MCPeerID(displayName: UIDevice.current.name),
            serviceType: serviceType
        )
        browser.delegate = self
        browser.startBrowsingForPeers()
        self.browser = browser
        hosts = []
        peerNames = [:]
    }

    func stop() {
        browser?.stopBrowsingForPeers()
        browser = nil
        hosts = []
        peerNames = [:]
    }
}

extension NearbyPeerBrowser: MCNearbyServiceBrowserDelegate {
    nonisolated func browser(
        _ browser: MCNearbyServiceBrowser,
        foundPeer peerID: MCPeerID,
        withDiscoveryInfo info: [String: String]?
    ) {
        Task { @MainActor in
            guard let info,
                  let participantID = info["participantID"],
                  let winLength = Int(info["winLength"] ?? ""),
                  let boardSize = BoardSize(rawValue: info["boardSize"] ?? "") else { return }
            peerNames[participantID] = peerID.displayName
            let host = DiscoveredHost(
                id: participantID,
                displayName: peerID.displayName,
                boardSize: boardSize,
                winLength: winLength
            )
            if let index = hosts.firstIndex(where: { $0.id == participantID }) {
                hosts[index] = host
            } else {
                hosts.append(host)
            }
        }
    }

    nonisolated func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        Task { @MainActor in
            let participantID = peerNames.first(where: { $0.value == peerID.displayName })?.key
            if let participantID {
                hosts.removeAll { $0.id == participantID }
                peerNames.removeValue(forKey: participantID)
            } else {
                hosts.removeAll { $0.displayName == peerID.displayName }
            }
        }
    }
}
