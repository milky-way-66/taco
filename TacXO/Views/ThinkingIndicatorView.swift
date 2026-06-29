import SwiftUI

struct ThinkingIndicatorView: View {
    @State private var activeDot = 0
    @State private var markPulse = false

    var body: some View {
        HStack(spacing: 6) {
            Text("○")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(GameTheme.oMark)
                .scaleEffect(markPulse ? 1.08 : 0.94)
                .opacity(markPulse ? 1 : 0.65)

            Text(String(localized: "neighbor_thinking"))
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.primary)

            HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(GameTheme.oMark.opacity(index == activeDot ? 1 : 0.22))
                        .frame(width: 5, height: 5)
                        .scaleEffect(index == activeDot ? 1.15 : 0.85)
                }
            }
        }
        .animation(GameTheme.thinkingPulse, value: activeDot)
        .animation(GameTheme.thinkingPulse, value: markPulse)
        .task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(380))
                activeDot = (activeDot + 1) % 3
                markPulse.toggle()
            }
        }
    }
}
