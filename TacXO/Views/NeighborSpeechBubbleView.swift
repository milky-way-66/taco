import SwiftUI

struct NeighborSpeechBubbleView: View {
    let name: String
    let text: String
    let mood: NeighborCommentMood

    @State private var isVisible = false
    @State private var entranceY: CGFloat = 56
    @State private var revealedCount = 0
    @State private var floatOffset: CGFloat = 0
    @State private var annoyanceShake: CGFloat = 0

    private var palette: BubblePalette {
        BubblePalette.forMood(mood)
    }

    private var graphemes: [Character] {
        Array(text)
    }

    private var displayedText: String {
        String(graphemes.prefix(revealedCount))
    }

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            avatar

            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(palette.accent)
                    .textCase(.uppercase)
                    .tracking(0.6)

                Text(displayedText)
                    .font(.system(.subheadline, design: .serif))
                    .italic()
                    .foregroundStyle(palette.text)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .background {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(palette.fill)
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(palette.stroke, lineWidth: 1)
                }
        }
        .offset(x: annoyanceShake, y: entranceY + floatOffset)
        .opacity(isVisible ? 1 : 0)
        .onAppear { runEntrance() }
        .onDisappear { resetState() }
    }

    private var avatar: some View {
        Text(palette.avatarMark)
            .font(.system(size: 15, weight: .bold))
            .foregroundStyle(palette.accent)
            .frame(width: 28, height: 28)
            .background {
                Circle()
                    .fill(palette.accent.opacity(0.12))
            }
            .rotationEffect(.degrees(mood == .disappointed ? annoyanceShake * 2.5 : 0))
    }

    private func runEntrance() {
        resetState()

        withAnimation(GameTheme.commentSpring) {
            isVisible = true
            entranceY = 0
        }

        if mood == .disappointed {
            withAnimation(.easeInOut(duration: 0.08).repeatCount(4, autoreverses: true).delay(0.25)) {
                annoyanceShake = 2.5
            }
            Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(520))
                annoyanceShake = 0
            }
        }

        withAnimation(.easeInOut(duration: 2.6).repeatForever(autoreverses: true).delay(0.5)) {
            floatOffset = -5
        }

        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(280))
            for index in 1...graphemes.count {
                guard !Task.isCancelled else { return }
                try? await Task.sleep(for: .milliseconds(typingDelay))
                revealedCount = index
            }
        }
    }

    private func resetState() {
        isVisible = false
        entranceY = 56
        revealedCount = 0
        floatOffset = 0
        annoyanceShake = 0
    }

    private var typingDelay: Int {
        switch mood {
        case .impressed: 20
        case .neutral: 24
        case .disappointed: 18
        }
    }
}

private struct BubblePalette {
    let accent: Color
    let text: Color
    let fill: Color
    let stroke: Color
    let avatarMark: String

    static func forMood(_ mood: NeighborCommentMood) -> BubblePalette {
        switch mood {
        case .impressed:
            BubblePalette(
                accent: Color(red: 0.52, green: 0.38, blue: 0.12),
                text: Color(red: 0.16, green: 0.24, blue: 0.34),
                fill: Color(red: 1.0, green: 0.99, blue: 0.96).opacity(0.92),
                stroke: Color(red: 0.85, green: 0.72, blue: 0.38).opacity(0.4),
                avatarMark: "◔"
            )
        case .neutral:
            BubblePalette(
                accent: GameTheme.oMark,
                text: Color(red: 0.14, green: 0.22, blue: 0.36),
                fill: Color.white.opacity(0.9),
                stroke: GameTheme.oMark.opacity(0.22),
                avatarMark: "○"
            )
        case .disappointed:
            BubblePalette(
                accent: Color(red: 0.62, green: 0.28, blue: 0.30),
                text: Color(red: 0.22, green: 0.14, blue: 0.18),
                fill: Color(red: 1.0, green: 0.97, blue: 0.97).opacity(0.92),
                stroke: Color(red: 0.82, green: 0.48, blue: 0.48).opacity(0.35),
                avatarMark: "◎"
            )
        }
    }
}
