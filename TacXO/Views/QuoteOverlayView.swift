import SwiftUI

struct QuoteOverlayView: View {
    let quote: NeighborQuote
    let kind: QuoteOverlayKind
    let language: AppLanguage
    let hardnessPercent: Int
    let hardnessDelta: Int
    let winStreak: Int
    let onDismiss: () -> Void

    @State private var showTitle = false
    @State private var showQuote = false
    @State private var showHardness = false
    @State private var showHint = false

    private var palette: QuotePalette {
        kind == .victory ? .victory : .defeat
    }

    private var titleKey: String.LocalizationValue {
        kind == .victory ? "win_victory" : "loss_defeated"
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
                .allowsHitTesting(false)

            VStack(spacing: 28) {
                VStack(spacing: 10) {
                    ornamentalLine
                        .opacity(showTitle ? 1 : 0)
                        .offset(y: showTitle ? 0 : 8)

                    Text(String(localized: titleKey, locale: language.locale))
                        .font(.system(size: kind == .victory ? 16 : 14, weight: .bold, design: .serif))
                        .tracking(6)
                        .foregroundStyle(palette.title)
                        .shadow(color: palette.titleGlow, radius: kind == .victory ? 10 : 6)
                        .opacity(showTitle ? 1 : 0)
                        .offset(y: showTitle ? 0 : 10)

                    ornamentalLine
                        .opacity(showTitle ? 1 : 0)
                        .offset(y: showTitle ? 0 : 8)
                }

                Text(quote.text(for: language))
                    .font(.system(size: 26, weight: .regular, design: .serif))
                    .italic()
                    .multilineTextAlignment(.center)
                    .foregroundStyle(palette.quote)
                    .lineSpacing(6)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    .background {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(palette.quoteBackground)
                    }
                    .padding(.horizontal, 20)
                    .opacity(showQuote ? 1 : 0)
                    .offset(y: showQuote ? 0 : 16)

                HardnessEndGameReveal(
                    previousPercent: hardnessPercent - hardnessDelta,
                    currentPercent: hardnessPercent,
                    delta: hardnessDelta,
                    winStreak: winStreak
                )
                .opacity(showHardness ? 1 : 0)
                .offset(y: showHardness ? 0 : 18)
                .scaleEffect(showHardness ? 1 : 0.92)

                Text(String(localized: "loss_tap_continue", locale: language.locale))
                    .font(.system(size: 12, weight: .medium, design: .serif))
                    .tracking(2)
                    .foregroundStyle(palette.hint)
                    .padding(.top, 8)
                    .opacity(showHint ? 1 : 0)
                    .offset(y: showHint ? 0 : 6)
            }
            .padding(.vertical, 28)
            .padding(.bottom, 12)
            .frame(maxWidth: .infinity)
            .background {
                ZStack {
                    Rectangle()
                        .fill(palette.backdropMaterial)

                    LinearGradient(
                        colors: palette.panelGradient,
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
                .ignoresSafeArea(edges: .bottom)
            }
        }
        .environment(\.locale, language.locale)
        .contentShape(Rectangle())
        .onTapGesture {
            onDismiss()
        }
        .onAppear {
            if kind == .victory {
                withAnimation(.spring(response: 0.55, dampingFraction: 0.72).delay(0.1)) { showTitle = true }
                withAnimation(.spring(response: 0.65, dampingFraction: 0.78).delay(0.3)) { showQuote = true }
            } else {
                withAnimation(.easeOut(duration: 0.7).delay(0.1)) { showTitle = true }
                withAnimation(.easeOut(duration: 0.85).delay(0.35)) { showQuote = true }
            }
            withAnimation(.spring(response: 0.62, dampingFraction: 0.78).delay(0.55)) { showHardness = true }
            withAnimation(.easeInOut(duration: 0.6).delay(1.2)) { showHint = true }
        }
    }

    private var ornamentalLine: some View {
        HStack(spacing: 12) {
            lineSegment
            Circle()
                .fill(palette.line.opacity(0.9))
                .frame(width: 5, height: 5)
            lineSegment
        }
        .frame(maxWidth: 220)
    }

    private var lineSegment: some View {
        LinearGradient(
            colors: [.clear, palette.line.opacity(0.8), .clear],
            startPoint: .leading,
            endPoint: .trailing
        )
        .frame(height: 1)
    }
}

private struct QuotePalette {
    let title: Color
    let titleGlow: Color
    let quote: Color
    let quoteBackground: Color
    let line: Color
    let panelGradient: [Color]
    let hint: Color
    let backdropMaterial: Material

    static let victory = QuotePalette(
        title: Color(red: 0.72, green: 0.52, blue: 0.08),
        titleGlow: Color(red: 0.85, green: 0.68, blue: 0.22).opacity(0.35),
        quote: Color(red: 0.05, green: 0.16, blue: 0.34),
        quoteBackground: Color.white.opacity(0.88),
        line: Color(red: 0.85, green: 0.68, blue: 0.22),
        panelGradient: [
            Color.white.opacity(0.82),
            Color.white.opacity(0.96),
            Color(red: 0.95, green: 0.97, blue: 1.0)
        ],
        hint: Color(red: 0.20, green: 0.34, blue: 0.52).opacity(0.82),
        backdropMaterial: .thickMaterial
    )

    static let defeat = QuotePalette(
        title: Color(red: 1.0, green: 0.58, blue: 0.58),
        titleGlow: Color(red: 0.95, green: 0.22, blue: 0.22).opacity(0.45),
        quote: Color(red: 0.98, green: 0.96, blue: 0.94),
        quoteBackground: Color.white.opacity(0.12),
        line: Color(red: 0.95, green: 0.45, blue: 0.45),
        panelGradient: [
            Color(red: 0.20, green: 0.08, blue: 0.10).opacity(0.94),
            Color(red: 0.14, green: 0.06, blue: 0.08).opacity(0.98),
            Color(red: 0.10, green: 0.05, blue: 0.06)
        ],
        hint: Color(red: 0.84, green: 0.82, blue: 0.80),
        backdropMaterial: .ultraThickMaterial
    )
}
