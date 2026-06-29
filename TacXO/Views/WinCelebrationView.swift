import SwiftUI

struct WinCelebrationView: View {
    let winStreak: Int

    @State private var flashOpacity = 0.0
    @State private var innerRing: CGFloat = 0.4
    @State private var outerRing: CGFloat = 0.3
    @State private var ringOpacity = 0.0

    private let gold = Color(red: 1.0, green: 0.88, blue: 0.45)
    private let green = Color(red: 0.28, green: 0.72, blue: 0.48)

    private var streakFireIntensity: Double {
        HardnessStyle.streakFireIntensity(for: winStreak)
    }

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

            if streakFireIntensity > 0 {
                HardnessFireAura(intensity: streakFireIntensity, style: .victory)
                    .frame(width: 280, height: 180)
                    .opacity(flashOpacity)
            }

            Circle()
                .stroke(gold.opacity(0.45), lineWidth: 2)
                .scaleEffect(outerRing)
                .opacity(ringOpacity)

            Circle()
                .stroke(green.opacity(0.55), lineWidth: 2.5)
                .scaleEffect(innerRing)
                .opacity(ringOpacity * 0.85)

            if winStreak >= HardnessStyle.streakFireThreshold {
                VStack(spacing: 8) {
                    WinStreakBadge(streak: winStreak)
                }
                .offset(y: -120)
                .opacity(ringOpacity)
            }
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
