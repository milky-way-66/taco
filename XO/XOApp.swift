import SwiftUI

@main
struct XOApp: App {
    @State private var controller = GameController()

    var body: some Scene {
        WindowGroup {
            PlayView(controller: controller)
                .onAppear {
                    _ = SoundManager.shared
                }
        }
    }
}
