import SwiftUI

struct GameBackgroundView: View {
    var body: some View {
        LinearGradient(
            colors: [GameTheme.backgroundTop, GameTheme.backgroundBottom],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}
