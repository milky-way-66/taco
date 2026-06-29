import SwiftUI

@main
struct XOApp: App {
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
