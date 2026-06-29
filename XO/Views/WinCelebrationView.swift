import SwiftUI

struct WinCelebrationView: View {
    @State private var flashOpacity = 0.0
    @State private var innerRing: CGFloat = 0.4
    @State private var outerRing: CGFloat = 0.3
    @State private var ringOpacity = 0.0

    private let gold = Color(red: 1.0, green: 0.88, blue: 0.45)
    private let green = Color(red: 0.28, green: 0.72, blue: 0.48)

    var body: some View {
        ZStack {
            RadialGradient(
                colors: [gold.opacity(0.35), green.opacity(0.12), .clear],
                center: .center,
                startRadius: 20,
                endRadius: 320
            )
            .opacity(flashOpacity)
            .ignoresSafeArea()

            Circle()
                .stroke(gold.opacity(0.45), lineWidth: 2)
                .scaleEffect(outerRing)
                .opacity(ringOpacity)

            Circle()
                .stroke(green.opacity(0.55), lineWidth: 2.5)
                .scaleEffect(innerRing)
                .opacity(ringOpacity * 0.85)
        }
        .allowsHitTesting(false)
        .onAppear {
            withAnimation(.easeOut(duration: 0.55)) {
                flashOpacity = 1
            }
            withAnimation(.easeOut(duration: 0.9)) {
                innerRing = 1.15
                outerRing = 1.45
                ringOpacity = 1
            }
            withAnimation(.easeIn(duration: 0.5).delay(0.85)) {
                flashOpacity = 0
                ringOpacity = 0
            }
        }
    }
}
