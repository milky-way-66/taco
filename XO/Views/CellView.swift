import SwiftUI

struct CellView: View {
    let mark: Mark?
    let size: CGFloat

    var body: some View {
        ZStack {
            Rectangle()
                .stroke(Color.gray.opacity(0.4), lineWidth: 1)
            if let mark {
                Text(mark == .x ? "✕" : "○")
                    .font(.system(size: size * 0.5, weight: .regular, design: .serif))
                    .foregroundStyle(mark == .x ? Color(red: 0.6, green: 0.2, blue: 0.2) : Color(red: 0.2, green: 0.3, blue: 0.6))
            }
        }
        .frame(width: size, height: size)
    }
}
