import SwiftUI

struct LossOverlayView: View {
    let quote: String

    var body: some View {
        ZStack {
            Color.black.opacity(0.35)
                .ignoresSafeArea()
            Text(quote)
                .font(.system(.title3, design: .serif))
                .multilineTextAlignment(.center)
                .padding(24)
                .background(Color(red: 0.98, green: 0.96, blue: 0.9))
                .cornerRadius(8)
                .shadow(radius: 4)
                .padding(32)
        }
    }
}
