import SwiftUI

@main
struct TacXOApp: App {
    @State private var controller = GameController()

    var body: some Scene {
        WindowGroup {
            PlayView(controller: controller)
                .environment(\.locale, controller.settings.language.locale)
                .onAppear {
                    _ = SoundManager.shared
                }
        }
    }
}
