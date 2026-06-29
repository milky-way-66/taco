import SwiftUI

enum HardnessStyle {
    static let minPercent = AdaptiveDifficulty.minHardness
    static let maxPercent = AdaptiveDifficulty.maxHardness
    static let fireThreshold = 150
    static let streakFireThreshold = AdaptiveDifficulty.streakFireThreshold

    static func color(for percent: Int) -> Color {
        let clamped = clamp(percent)
        let t = Double(clamped - minPercent) / Double(maxPercent - minPercent)

        if clamped < 50 {
            return Color(red: 0.34, green: 0.68, blue: 0.88)
        }
        if clamped < 85 {
            return Color(red: 0.42, green: 0.56, blue: 0.66)
        }
        if clamped < 115 {
            return Color(red: 0.28, green: 0.34, blue: 0.42)
        }
        if clamped < fireThreshold {
            return Color(red: 0.94, green: 0.52, blue: 0.14)
        }

        let heat = min(1, (t - 0.75) / 0.25)
        return Color(
            red: 0.92 + heat * 0.03,
            green: 0.28 - heat * 0.12,
            blue: 0.1 - heat * 0.04
        )
    }

    static func glow(for percent: Int) -> Color {
        color(for: percent).opacity(showsFire(for: percent) ? 0.65 : 0.28)
    }

    static func capsuleFill(for percent: Int) -> Color {
        color(for: percent).opacity(showsFire(for: percent) ? 0.2 : 0.12)
    }

    static func capsuleStroke(for percent: Int) -> Color {
        color(for: percent).opacity(showsFire(for: percent) ? 0.55 : 0.28)
    }

    static func showsFire(for percent: Int) -> Bool {
        clamp(percent) >= fireThreshold
    }

    static func showsFire(hardness percent: Int, winStreak: Int) -> Bool {
        showsFire(for: percent) || winStreak >= streakFireThreshold
    }

    static func fireIntensity(for percent: Int) -> Double {
        let clamped = clamp(percent)
        guard clamped >= fireThreshold else { return 0 }
        return min(1, Double(clamped - fireThreshold) / Double(maxPercent - fireThreshold))
    }

    static func streakFireIntensity(for winStreak: Int) -> Double {
        guard winStreak >= streakFireThreshold else { return 0 }
        return min(1, Double(winStreak - 1) / 5.0)
    }

    static func fireIntensity(hardness percent: Int, winStreak: Int) -> Double {
        max(fireIntensity(for: percent), streakFireIntensity(for: winStreak))
    }

    static func glow(hardness percent: Int, winStreak: Int) -> Color {
        let intensity = fireIntensity(hardness: percent, winStreak: winStreak)
        let base = winStreak >= streakFireThreshold && fireIntensity(for: percent) == 0
            ? Color(red: 1, green: 0.72, blue: 0.18)
            : color(for: percent)
        return base.opacity(intensity > 0 ? 0.45 + intensity * 0.25 : 0.28)
    }

    static func deltaColor(for delta: Int) -> Color {
        delta >= 0
            ? Color(red: 0.98, green: 0.58, blue: 0.12)
            : Color(red: 0.34, green: 0.78, blue: 0.62)
    }

    private static func clamp(_ percent: Int) -> Int {
        min(maxPercent, max(minPercent, percent))
    }
}

struct HardnessNavBadge: View {
    let percent: Int
    let winStreak: Int

    private var fireIntensity: Double {
        HardnessStyle.fireIntensity(hardness: percent, winStreak: winStreak)
    }

    var body: some View {
        ZStack {
            if HardnessStyle.showsFire(hardness: percent, winStreak: winStreak) {
                HardnessFireAura(
                    intensity: fireIntensity,
                    style: winStreak >= HardnessStyle.streakFireThreshold && HardnessStyle.fireIntensity(for: percent) == 0
                        ? .victory
                        : .heat
                )
                .frame(width: 52, height: 34)
            }

            Text(String(format: String(localized: "hardness_nav"), percent))
                .font(.caption.weight(.bold).monospacedDigit())
                .foregroundStyle(HardnessStyle.color(for: percent))
                .padding(.horizontal, 9)
                .padding(.vertical, 5)
                .background {
                    Capsule()
                        .fill(HardnessStyle.capsuleFill(for: percent))
                        .overlay {
                            Capsule()
                                .strokeBorder(HardnessStyle.capsuleStroke(for: percent), lineWidth: 1)
                        }
                }
                .shadow(color: HardnessStyle.glow(hardness: percent, winStreak: winStreak), radius: fireIntensity > 0 ? 8 : 0)
                .contentTransition(.numericText())
        }
        .accessibilityLabel(
            String(format: String(localized: "hardness_accessibility"), percent)
        )
        .animation(.spring(response: 0.45, dampingFraction: 0.78), value: percent)
        .animation(.spring(response: 0.45, dampingFraction: 0.78), value: winStreak)
    }
}

struct HardnessEndGameReveal: View {
    let previousPercent: Int
    let currentPercent: Int
    let delta: Int
    let winStreak: Int

    @State private var displayedPercent: Int
    @State private var deltaLift: CGFloat = 14
    @State private var deltaOpacity = 0.0
    @State private var numberScale: CGFloat = 1.0
    @State private var glowPulse = false

    init(previousPercent: Int, currentPercent: Int, delta: Int, winStreak: Int) {
        self.previousPercent = previousPercent
        self.currentPercent = currentPercent
        self.delta = delta
        self.winStreak = winStreak
        _displayedPercent = State(initialValue: previousPercent)
    }

    private var fireIntensity: Double {
        HardnessStyle.fireIntensity(hardness: displayedPercent, winStreak: winStreak)
    }

    private var fireStyle: HardnessFireAura.Style {
        winStreak >= HardnessStyle.streakFireThreshold && HardnessStyle.fireIntensity(for: displayedPercent) == 0
            ? .victory
            : .heat
    }

    var body: some View {
        VStack(spacing: 10) {
            Text(String(localized: "hardness_label"))
                .font(.system(size: 11, weight: .semibold, design: .serif))
                .tracking(3)
                .foregroundStyle(.secondary)

            ZStack {
                if HardnessStyle.showsFire(hardness: displayedPercent, winStreak: winStreak) {
                    HardnessFireAura(intensity: fireIntensity, style: fireStyle)
                        .frame(width: 180, height: 110)
                }

                Text("\(displayedPercent)%")
                    .font(.system(size: 64, weight: .black, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(HardnessStyle.color(for: displayedPercent))
                    .shadow(color: HardnessStyle.glow(hardness: displayedPercent, winStreak: winStreak), radius: glowPulse ? 18 : 8)
                    .scaleEffect(numberScale)
                    .contentTransition(.numericText())

                deltaBadge
                    .offset(y: -52 + deltaLift)
                    .opacity(deltaOpacity)
            }
            .frame(height: 92)

            if winStreak >= HardnessStyle.streakFireThreshold, delta > 0 {
                WinStreakBadge(streak: winStreak)
            }
        }
        .onAppear(perform: runReveal)
    }

    private var deltaBadge: some View {
        Text(delta >= 0 ? "+\(delta)%" : "\(delta)%")
            .font(.system(size: 22, weight: .heavy, design: .rounded))
            .monospacedDigit()
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background {
                Capsule()
                    .fill(HardnessStyle.deltaColor(for: delta).gradient)
                    .shadow(color: HardnessStyle.deltaColor(for: delta).opacity(0.55), radius: 10, y: 4)
            }
    }

    private func runReveal() {
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(420))

            withAnimation(.spring(response: 0.42, dampingFraction: 0.62)) {
                deltaOpacity = 1
                deltaLift = 0
            }

            try? await Task.sleep(for: .milliseconds(520))

            withAnimation(.spring(response: 0.5, dampingFraction: 0.72)) {
                displayedPercent = currentPercent
                numberScale = 1.1
                glowPulse = true
            }

            try? await Task.sleep(for: .milliseconds(180))
            withAnimation(.spring(response: 0.38, dampingFraction: 0.8)) {
                numberScale = 1
            }

            try? await Task.sleep(for: .milliseconds(700))
            withAnimation(.easeOut(duration: 0.45)) {
                deltaLift = -28
                deltaOpacity = 0
            }
        }
    }
}

struct HardnessFireAura: View {
    enum Style {
        case heat
        case victory
    }

    let intensity: Double
    var style: Style = .heat

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate

            ZStack {
                ForEach(0..<flameCount, id: \.self) { index in
                    flame(time: time, index: index)
                }
            }
        }
        .allowsHitTesting(false)
        .blendMode(.plusLighter)
    }

    private var flameCount: Int {
        4 + Int(intensity * 4)
    }

    private func flame(time: TimeInterval, index: Int) -> some View {
        let angle = Double(index) / Double(max(flameCount, 1)) * .pi * 2
        let flicker = sin(time * 9 + Double(index) * 1.35)
        let breathe = cos(time * 5 + Double(index) * 0.8)
        let radius = 16 + intensity * 8
        let xOffset = CGFloat(cos(angle)) * radius
        let yOffset = CGFloat(sin(angle)) * (radius * 0.72) - 6
        let size = 9 + CGFloat(intensity * 5) + CGFloat(index % 2) * 2
        let opacity = 0.45 + intensity * 0.35 + flicker * 0.18
        let scale = 0.85 + intensity * 0.2 + flicker * 0.12
        let rotation = breathe * 10 + Double(index) * 8
        let symbol = index.isMultiple(of: 2) ? "flame.fill" : "flame"

        return Image(systemName: symbol)
            .font(.system(size: size))
            .foregroundStyle(flameGradient)
            .opacity(opacity)
            .scaleEffect(scale)
            .rotationEffect(.degrees(rotation))
            .offset(x: xOffset, y: yOffset)
    }

    private var flameGradient: LinearGradient {
        switch style {
        case .heat:
            return LinearGradient(
                colors: [
                    Color(red: 1, green: 0.95, blue: 0.45).opacity(0.95),
                    Color(red: 1, green: 0.55, blue: 0.08),
                    Color(red: 0.92, green: 0.18, blue: 0.05)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        case .victory:
            return LinearGradient(
                colors: [
                    Color(red: 1, green: 0.98, blue: 0.62),
                    Color(red: 1, green: 0.78, blue: 0.18),
                    Color(red: 0.98, green: 0.42, blue: 0.08)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
}

struct WinStreakBadge: View {
    let streak: Int

    var body: some View {
        HStack(spacing: 6) {
            HardnessFireAura(intensity: HardnessStyle.streakFireIntensity(for: streak), style: .victory)
                .frame(width: 34, height: 22)

            Text(String(format: String(localized: "win_streak_format"), streak))
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(Color(red: 1, green: 0.72, blue: 0.18))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background {
            Capsule()
                .fill(Color(red: 1, green: 0.72, blue: 0.18).opacity(0.14))
                .overlay {
                    Capsule()
                        .strokeBorder(Color(red: 1, green: 0.72, blue: 0.18).opacity(0.35), lineWidth: 1)
                }
        }
    }
}
