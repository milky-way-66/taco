import SwiftUI

struct NearbyWaitingView: View {
    let settings: GameSettings
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "antenna.radiowaves.left.and.right")
                .font(.system(size: 48))
                .foregroundStyle(.tint)
                .symbolEffect(.pulse)

            Text(String(localized: "nearby_waiting"))
                .font(.title3.weight(.semibold))
                .multilineTextAlignment(.center)

            Text(rulesSummary)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()

            Button(String(localized: "nearby_cancel"), role: .cancel, action: onCancel)
                .buttonStyle(.bordered)
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var rulesSummary: String {
        String(
            format: String(localized: "nearby_rules_format"),
            settings.boardSize.rawValue,
            settings.winLength
        )
    }
}
