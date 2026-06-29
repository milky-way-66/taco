import SwiftUI

struct CellView: View {
    let mark: Mark?
    let size: CGFloat
    var isWinning = false
    var isLatest = false
    var winStaggerIndex = 0

    @State private var winPulse = false

    var body: some View {
        ZStack {
            Rectangle()
                .fill(backgroundFill)

            if let mark {
                Text(mark == .x ? "✕" : "○")
                    .font(.system(size: size * 0.52, weight: .medium, design: .rounded))
                    .foregroundStyle(mark == .x ? GameTheme.xMark : GameTheme.oMark)
                    .scaleEffect(isWinning && winPulse ? 1.12 : 1)
            }
        }
        .frame(width: size, height: size)
        .overlay {
            Rectangle()
                .strokeBorder(
                    isWinning && winPulse ? GameTheme.winGold.opacity(0.85) : GameTheme.gridLine,
                    lineWidth: isWinning && winPulse ? 1.5 : 0.5
                )
        }
        .scaleEffect(isWinning && winPulse ? 1.05 : 1)
        .shadow(
            color: isWinning && winPulse ? GameTheme.winGold.opacity(0.45) : .clear,
            radius: 6
        )
        .animation(.easeOut(duration: 0.2), value: mark)
        .onChange(of: isWinning) { _, winning in
            guard winning else {
                winPulse = false
                return
            }
            let delay = Double(winStaggerIndex) * 0.065
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.spring(response: 0.38, dampingFraction: 0.58)) {
                    winPulse = true
                }
            }
        }
    }

    private var backgroundFill: Color {
        if isWinning {
            return GameTheme.winHighlight.opacity(winPulse ? 0.75 : 0.45)
        }
        if isLatest {
            return Color.accentColor.opacity(0.08)
        }
        return Color.clear
    }
}
