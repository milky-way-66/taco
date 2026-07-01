import SwiftUI

struct NearbyBrowseView: View {
    let hosts: [DiscoveredHost]
    let onJoin: (DiscoveredHost) -> Void

    var body: some View {
        Group {
            if hosts.isEmpty {
                VStack(spacing: 16) {
                    Spacer()
                    Image(systemName: "wifi.slash")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                    Text(String(localized: "nearby_no_games"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    ProgressView()
                    Spacer()
                }
                .padding(32)
            } else {
                List(hosts) { host in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(host.displayName)
                                .font(.headline)
                            Text(
                                String(
                                    format: String(localized: "nearby_rules_format"),
                                    host.boardSize.rawValue,
                                    host.winLength
                                )
                            )
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Button(String(localized: "nearby_join")) {
                            onJoin(host)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding(.vertical, 4)
                }
                .listStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
