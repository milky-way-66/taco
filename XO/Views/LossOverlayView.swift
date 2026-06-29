import SwiftUI

struct LossOverlayView: View {
    let quote: NeighborQuote
    let language: AppLanguage

    var body: some View {
        ZStack {
            Color.black.opacity(0.35)
                .ignoresSafeArea()
            ScrollView {
                VStack(spacing: 12) {
                    Text(quote.text(for: language))
                        .font(.system(.title3, design: .serif))
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)

                    Divider()
                        .padding(.horizontal, 8)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("🇬🇧 \(quote.explanationEnglish)")
                            .font(.system(.footnote, design: .default))
                            .foregroundStyle(.secondary)
                        Text("🇻🇳 \(quote.explanationVietnamese)")
                            .font(.system(.footnote, design: .default))
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(24)
            }
            .frame(maxHeight: 360)
            .background(Color(red: 0.98, green: 0.96, blue: 0.9))
            .cornerRadius(8)
            .shadow(radius: 4)
            .padding(24)
        }
    }
}
