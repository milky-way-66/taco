import SwiftUI

struct PaperBackgroundView: View {
    var body: some View {
        ZStack {
            Color(red: 0.96, green: 0.94, blue: 0.90)
            Image("paper_texture")
                .resizable(resizingMode: .tile)
                .opacity(0.42)
                .blendMode(.multiply)
        }
        .ignoresSafeArea()
    }
}
