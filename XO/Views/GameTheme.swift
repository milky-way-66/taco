import SwiftUI

enum GameTheme {
    static let backgroundTop = Color(red: 0.97, green: 0.97, blue: 0.98)
    static let backgroundBottom = Color(red: 0.91, green: 0.93, blue: 0.97)
    static let boardSurface = Color.white
    static let gridLine = Color(red: 0.82, green: 0.84, blue: 0.88)
    static let xMark = Color(red: 0.55, green: 0.22, blue: 0.28)
    static let oMark = Color(red: 0.18, green: 0.36, blue: 0.62)
    static let winHighlight = Color(red: 1.0, green: 0.92, blue: 0.55)
    static let winGold = Color(red: 0.92, green: 0.72, blue: 0.22)

    static let markSpring = Animation.smooth(duration: 0.42)
    static let boardSpring = Animation.smooth(duration: 0.5)
    static let overlaySpring = Animation.smooth(duration: 0.55)
    static let newGameSpring = Animation.spring(response: 0.55, dampingFraction: 0.82)
    static let newGameExit = Animation.easeIn(duration: 0.24)

    static func cellSize(dimension: Int, availableSize: CGSize) -> CGFloat {
        let horizontalInset: CGFloat = 20
        let verticalInset: CGFloat = 12
        let maxFromWidth = (availableSize.width - horizontalInset) / CGFloat(dimension)
        let maxFromHeight = (availableSize.height - verticalInset) / CGFloat(dimension)
        let computed = min(maxFromWidth, maxFromHeight)

        if needsScrolling(dimension: dimension, availableSize: availableSize) {
            return min(max(availableSize.width / 9, 30), 40)
        }
        return min(max(computed, 34), 88)
    }

    static func needsScrolling(dimension: Int, availableSize: CGSize) -> Bool {
        let horizontalInset: CGFloat = 20
        let verticalInset: CGFloat = 12
        let maxFromWidth = (availableSize.width - horizontalInset) / CGFloat(dimension)
        let maxFromHeight = (availableSize.height - verticalInset) / CGFloat(dimension)
        return min(maxFromWidth, maxFromHeight) < 34
    }
}
