import SwiftUI

@main
struct TacXOApp: App {
    @State private var controller = GameController()
    @State private var nearbyController = NearbyGameController(settings: .load())

    var body: some Scene {
        WindowGroup {
            PlayView(controller: controller, nearbyController: nearbyController)
                .environment(\.locale, controller.settings.language.locale)
                .preferredColorScheme(.light)
                .task {
                    await setupNearbyServices()
                }
                .onAppear {
                    _ = SoundManager.shared
                }
        }
    }

    @MainActor
    private func setupNearbyServices() async {
        do {
            let transferService = try TransferService()
            let gameService = NearbyGameService(transferService: transferService)
            nearbyController.configure(service: gameService)
            if controller.settings.mode == .nearbyPvP {
                nearbyController.settings = controller.settings
                nearbyController.beginSessionIfNeeded()
            }
        } catch {
            // Nearby PvP unavailable if engine fails to initialize.
        }
    }
}
