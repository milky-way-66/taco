import AVFoundation
import UIKit

final class SoundManager {
    static let shared = SoundManager()

    private var players: [String: AVAudioPlayer] = [:]

    private init() {
        try? AVAudioSession.sharedInstance().setCategory(.ambient)
        try? AVAudioSession.sharedInstance().setActive(true)
        preload("place")
        preload("neighbor_loss_1")
        preload("neighbor_loss_2")
        preload("neighbor_loss_3")
    }

    func playPlace() {
        play("place")
        lightHaptic()
    }

    func playNeighborLoss() {
        let index = Int.random(in: 1...3)
        play("neighbor_loss_\(index)")
        errorHaptic()
    }

    func playWin() {
        successHaptic()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
    }

    private func preload(_ name: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: "wav") else { return }
        players[name] = try? AVAudioPlayer(contentsOf: url)
        players[name]?.prepareToPlay()
    }

    private func play(_ name: String) {
        players[name]?.currentTime = 0
        players[name]?.play()
    }

    private func lightHaptic() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    private func errorHaptic() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }

    private func successHaptic() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}
