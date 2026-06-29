import SwiftUI

struct QuoteOverlayView: View {
    let quote: NeighborQuote
    let kind: QuoteOverlayKind
    let language: AppLanguage
    let onDismiss: () -> Void

    @State private var showTitle = false
    @State private var showQuote = false
    @State private var showDetails = false
    @State private var showHint = false

    private var palette: QuotePalette {
        kind == .victory ? .victory : .defeat
    }

    private var titleKey: String.LocalizationValue {
        kind == .victory ? "win_victory" : "loss_defeated"
    }

    private var subtitleKey: String.LocalizationValue {
        kind == .victory ? "win_neighbor_mutters" : "loss_neighbor_says"
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

                    Text(String(localized: titleKey))
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
                    .padding(.horizontal, 28)
                    .opacity(showQuote ? 1 : 0)
                    .offset(y: showQuote ? 0 : 16)

                VStack(spacing: 14) {
                    Text(String(localized: subtitleKey))
                        .font(.system(size: 11, weight: .semibold, design: .serif))
                        .tracking(3)
                        .foregroundStyle(palette.subtitle)

                    VStack(alignment: .leading, spacing: 10) {
                        explanationRow(flag: "🇬🇧", text: quote.explanationEnglish)
                        explanationRow(flag: "🇻🇳", text: quote.explanationVietnamese)
                    }
                }
                .padding(.horizontal, 32)
                .opacity(showDetails ? 1 : 0)
                .offset(y: showDetails ? 0 : 12)

                Text(String(localized: "loss_tap_continue"))
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
                LinearGradient(
                    colors: palette.panelGradient,
                    startPoint: .top,
                    endPoint: .bottom
                )
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
            withAnimation(.easeOut(duration: 0.7).delay(0.9)) { showDetails = true }
            withAnimation(.easeInOut(duration: 0.6).delay(1.6)) { showHint = true }
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

    private func explanationRow(flag: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text(flag)
                .font(.footnote)
            Text(text)
                .font(.system(.footnote, design: .serif))
                .foregroundStyle(palette.explanation)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct QuotePalette {
    let title: Color
    let titleGlow: Color
    let quote: Color
    let subtitle: Color
    let explanation: Color
    let line: Color
    let panelGradient: [Color]
    let hint: Color

    static let victory = QuotePalette(
        title: Color(red: 0.85, green: 0.68, blue: 0.22),
        titleGlow: Color(red: 0.85, green: 0.68, blue: 0.22).opacity(0.4),
        quote: Color(red: 0.12, green: 0.28, blue: 0.52),
        subtitle: Color(red: 0.18, green: 0.36, blue: 0.62),
        explanation: Color(red: 0.28, green: 0.38, blue: 0.52).opacity(0.85),
        line: Color(red: 0.85, green: 0.68, blue: 0.22),
        panelGradient: [
            Color.white.opacity(0),
            Color.white.opacity(0.94),
            Color(red: 0.95, green: 0.97, blue: 1.0)
        ],
        hint: Color(red: 0.18, green: 0.36, blue: 0.62).opacity(0.6)
    )

    static let defeat = QuotePalette(
        title: Color(red: 0.92, green: 0.28, blue: 0.28),
        titleGlow: Color(red: 0.75, green: 0.12, blue: 0.12).opacity(0.55),
        quote: Color.white.opacity(0.93),
        subtitle: Color(red: 0.88, green: 0.32, blue: 0.32),
        explanation: Color.white.opacity(0.48),
        line: Color(red: 0.82, green: 0.22, blue: 0.22),
        panelGradient: [
            Color.black.opacity(0),
            Color(red: 0.1, green: 0.05, blue: 0.07).opacity(0.92),
            Color(red: 0.06, green: 0.04, blue: 0.05)
        ],
        hint: Color.white.opacity(0.38)
    )
}
