import SwiftUI

struct NearbyHostLobbyView: View {
    let settings: GameSettings
    let isWaiting: Bool
    let onHost: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "antenna.radiowaves.left.and.right")
                .font(.system(size: 48))
                .foregroundStyle(isWaiting ? Color.accentColor : Color.secondary)
                .symbolEffect(.pulse, isActive: isWaiting)

            Text(isWaiting
                 ? String(localized: "nearby_waiting")
                 : String(localized: "nearby_host_ready"))
                .font(.title3.weight(.semibold))
                .multilineTextAlignment(.center)

            Text(rulesSummary)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()

            if isWaiting {
                Button(String(localized: "nearby_cancel"), role: .cancel, action: onCancel)
                    .buttonStyle(.bordered)
            } else {
                Button(String(localized: "nearby_start_host"), action: onHost)
                    .buttonStyle(.borderedProminent)
            }
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
