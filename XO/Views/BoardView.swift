import SwiftUI

struct BoardView: View {
    let engine: GameEngine
    let isInteractive: Bool
    let onTap: (Cell) -> Void

    var body: some View {
        GeometryReader { geometry in
            let dim = engine.settings.boardSize.dimension
            if GameTheme.needsScrolling(dimension: dim, availableSize: geometry.size) {
                scrollableBoard(dimension: dim, in: geometry.size)
            } else {
                fixedBoard(dimension: dim, in: geometry.size)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private func fixedBoard(dimension dim: Int, in size: CGSize) -> some View {
        let cellSize = GameTheme.cellSize(dimension: dim, availableSize: size)
        let boardSize = cellSize * CGFloat(dim)

        boardCard {
            grid(dimension: dim, cellSize: cellSize)
                .frame(width: boardSize, height: boardSize)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .transition(.opacity.combined(with: .scale(scale: 0.94)))
    }

    @ViewBuilder
    private func scrollableBoard(dimension dim: Int, in size: CGSize) -> some View {
        let cellSize = GameTheme.cellSize(dimension: dim, availableSize: size)
        let boardSize = cellSize * CGFloat(dim)

        ScrollViewReader { proxy in
            ScrollView([.horizontal, .vertical], showsIndicators: false) {
                grid(dimension: dim, cellSize: cellSize)
                    .frame(width: boardSize, height: boardSize)
            }
            .frame(width: size.width, height: size.height)
            .onChange(of: engine.lastPlayedCell) { _, newCell in
                guard let newCell else { return }
                withAnimation(GameTheme.boardSpring) {
                    proxy.scrollTo(newCell, anchor: .center)
                }
            }
        }
    }

    @ViewBuilder
    private func grid(dimension dim: Int, cellSize: CGFloat) -> some View {
        VStack(spacing: 0) {
            ForEach(0..<dim, id: \.self) { y in
                HStack(spacing: 0) {
                    ForEach(0..<dim, id: \.self) { x in
                        let cell = Cell(x: x, y: y)
                        cellButton(at: cell, size: cellSize)
                            .id(cell)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func boardCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .background(GameTheme.boardSurface)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: .black.opacity(0.1), radius: 16, y: 6)
    }

    @ViewBuilder
    private func cellButton(at cell: Cell, size: CGFloat) -> some View {
        let canPlay = isInteractive && engine.canPlay(at: cell)

        Button {
            onTap(cell)
        } label: {
            CellView(
                mark: engine.cells[cell],
                size: size,
                isWinning: engine.winningCells.contains(cell),
                isLatest: engine.lastPlayedCell == cell,
                winStaggerIndex: winStaggerIndex(for: cell)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .allowsHitTesting(canPlay)
    }

    private func winStaggerIndex(for cell: Cell) -> Int {
        let ordered = engine.winningCells.sorted {
            if $0.y != $1.y { return $0.y < $1.y }
            return $0.x < $1.x
        }
        return ordered.firstIndex(of: cell) ?? 0
    }
}
