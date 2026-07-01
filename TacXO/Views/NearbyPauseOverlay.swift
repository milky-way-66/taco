import SwiftUI

struct NearbyPauseOverlay: View {
    let onForfeit: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.35)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                ProgressView()
                    .controlSize(.large)

                Text(String(localized: "nearby_paused"))
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.primary)

                Button(String(localized: "nearby_forfeit"), role: .destructive, action: onForfeit)
                    .buttonStyle(.bordered)
            }
            .padding(28)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
            .padding(32)
        }
    }
}
