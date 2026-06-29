import SwiftUI

struct BoardView: View {
    let engine: GameEngine
    let onTap: (Cell) -> Void

    private let cellSize: CGFloat = 44

    var body: some View {
        Group {
            if engine.settings.boardSize == .infinite {
                infiniteBoard
            } else {
                fixedBoard
            }
        }
    }

    private var fixedBoard: some View {
        let dim = engine.settings.boardSize.dimension ?? 3
        return VStack(spacing: 0) {
            ForEach(0..<dim, id: \.self) { y in
                HStack(spacing: 0) {
                    ForEach(0..<dim, id: \.self) { x in
                        let cell = Cell(x: x, y: y)
                        CellView(mark: engine.cells[cell], size: cellSize)
                            .onTapGesture { onTap(cell) }
                    }
                }
            }
        }
    }

    private var infiniteBoard: some View {
        let bounds = visibleBounds()
        return ScrollView([.horizontal, .vertical]) {
            VStack(spacing: 0) {
                ForEach(bounds.minY...bounds.maxY, id: \.self) { y in
                    HStack(spacing: 0) {
                        ForEach(bounds.minX...bounds.maxX, id: \.self) { x in
                            let cell = Cell(x: x, y: y)
                            CellView(mark: engine.cells[cell], size: cellSize)
                                .onTapGesture { onTap(cell) }
                        }
                    }
                }
            }
        }
    }

    private func visibleBounds() -> (minX: Int, maxX: Int, minY: Int, maxY: Int) {
        var minX = -3, maxX = 3, minY = -3, maxY = 3
        for (cell, _) in engine.cells {
            minX = min(minX, cell.x - 2)
            maxX = max(maxX, cell.x + 2)
            minY = min(minY, cell.y - 2)
            maxY = max(maxY, cell.y + 2)
        }
        return (minX, maxX, minY, maxY)
    }
}
