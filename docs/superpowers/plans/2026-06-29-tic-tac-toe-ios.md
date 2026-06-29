# Tic-Tac-Toe iOS Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a minimal iOS tic-tac-toe app with configurable rules, paper aesthetic, 2-player local play, and an adaptive "Neighbor" AI with toxic quotes and sound.

**Architecture:** Thin layers in a single Xcode target — pure Swift `GameEngine` (testable), `AIPlayer` with adaptive difficulty, `GameController` as `@Observable` bridge, SwiftUI views for Play and Settings only.

**Tech Stack:** Swift 5.9+, SwiftUI, iOS 17+, XCTest, UserDefaults, AVFoundation, UIKit haptics

**Spec:** `docs/superpowers/specs/2026-06-29-tic-tac-toe-ios-design.md`

---

## File Map

| File | Responsibility |
|------|----------------|
| `TacXO/TacXOApp.swift` | App entry, inject `GameController` |
| `TacXO/Models/Mark.swift` | X / O enum |
| `TacXO/Models/Cell.swift` | Grid coordinate, Hashable |
| `TacXO/Models/GameSettings.swift` | Rules + UserDefaults persistence |
| `TacXO/Engine/WinChecker.swift` | K-in-a-row from last move |
| `TacXO/Engine/GameEngine.swift` | Board state, moves, outcomes |
| `TacXO/AI/AdaptiveDifficulty.swift` | Level 0–5 up/down |
| `TacXO/AI/AIPlayer.swift` | Minimax + heuristics |
| `TacXO/Personality/NeighborQuotes.swift` | Quote list + random |
| `TacXO/Personality/SoundManager.swift` | SFX + haptics |
| `TacXO/ViewModels/GameController.swift` | UI state, AI turns, loss flow |
| `TacXO/Views/CellView.swift` | Single cell mark rendering |
| `TacXO/Views/BoardView.swift` | Grid, pan, tap handling |
| `TacXO/Views/LossOverlayView.swift` | Neighbor quote popup |
| `TacXO/Views/PlayView.swift` | Main game screen |
| `TacXO/Views/SettingsView.swift` | Rules form |
| `TacXO/Resources/` | Texture + audio assets |
| `TacXOTests/` | Unit tests for engine + AI |

---

### Task 1: Xcode project scaffold

**Files:**
- Create: Xcode project `TacXO.xcodeproj` (iOS App + Unit Test target)
- Create: folder structure under `TacXO/` and `TacXOTests/`

- [ ] **Step 1: Create Xcode project**

In Xcode (or via `xcodebuild` after project creation):

1. **File → New → Project → iOS → App**
2. Product Name: `TacXO`
3. Interface: **SwiftUI**, Language: **Swift**
4. Include **Unit Tests** (creates `TacXOTests` target)
5. Deployment target: **iOS 17.0**
6. Bundle ID: `com.tacxo.game`
7. Save into repo root: `/Users/khang/work/side-project/xo/`

- [ ] **Step 2: Create folder groups matching spec**

Create groups (with folder references) inside the `TacXO` target:

```
TacXO/
├── Models/
├── Engine/
├── AI/
├── Personality/
├── ViewModels/
├── Views/
└── Resources/
```

Delete the default `ContentView.swift` — replaced in later tasks.

- [ ] **Step 3: Verify build**

Run:

```bash
cd /Users/khang/work/side-project/xo
xcodebuild -scheme TacXO -destination 'platform=iOS Simulator,name=iPhone 16' build
```

Expected: `BUILD SUCCEEDED`

- [ ] **Step 4: Commit**

```bash
git add TacXO.xcodeproj TacXO/ TacXOTests/
git commit -m "chore: scaffold TacXO iOS project with test target"
```

---

### Task 2: Core models

**Files:**
- Create: `TacXO/Models/Mark.swift`
- Create: `TacXO/Models/Cell.swift`
- Create: `TacXO/Models/GameSettings.swift`

- [ ] **Step 1: Create Mark.swift**

```swift
import Foundation

enum Mark: String, Codable, Equatable {
    case x
    case o

    var opponent: Mark {
        switch self {
        case .x: return .o
        case .o: return .x
        }
    }

    var label: String {
        rawValue.uppercased()
    }
}
```

- [ ] **Step 2: Create Cell.swift**

```swift
import Foundation

struct Cell: Hashable, Codable {
    let x: Int
    let y: Int
}
```

- [ ] **Step 3: Create GameSettings.swift**

```swift
import Foundation

enum BoardSize: String, Codable, CaseIterable, Identifiable {
    case three = "3×3"
    case five = "5×5"
    case ten = "10×10"
    case infinite = "∞"

    var id: String { rawValue }

    /// nil means unbounded (infinite mode)
    var dimension: Int? {
        switch self {
        case .three: return 3
        case .five: return 5
        case .ten: return 10
        case .infinite: return nil
        }
    }
}

enum GameMode: String, Codable, CaseIterable, Identifiable {
    case twoPlayer = "2 Players"
    case vsNeighbor = "vs Neighbor"

    var id: String { rawValue }
}

struct GameSettings: Codable, Equatable {
    var winLength: Int = 5
    var boardSize: BoardSize = .five
    var mode: GameMode = .vsNeighbor

    static let `default` = GameSettings()

    private static let storageKey = "xo.game.settings"

    static func load() -> GameSettings {
        guard
            let data = UserDefaults.standard.data(forKey: storageKey),
            let settings = try? JSONDecoder().decode(GameSettings.self, from: data)
        else {
            return .default
        }
        return settings
    }

    func save() {
        guard let data = try? JSONEncoder().encode(self) else { return }
        UserDefaults.standard.set(data, forKey: Self.storageKey)
    }
}
```

- [ ] **Step 4: Add files to TacXO target and build**

Run:

```bash
xcodebuild -scheme TacXO -destination 'platform=iOS Simulator,name=iPhone 16' build
```

Expected: `BUILD SUCCEEDED`

- [ ] **Step 5: Commit**

```bash
git add TacXO/Models/
git commit -m "feat: add Mark, Cell, and GameSettings models"
```

---

### Task 3: WinChecker (TDD)

**Files:**
- Create: `TacXO/Engine/WinChecker.swift`
- Create: `TacXOTests/WinCheckerTests.swift`

- [ ] **Step 1: Write failing tests**

```swift
import XCTest
@testable import TacXO

final class WinCheckerTests: XCTestCase {
    func testHorizontalWin() {
        var cells: [Cell: Mark] = [:]
        for x in 0..<5 { cells[Cell(x: x, y: 0)] = .x }
        XCTAssertTrue(WinChecker.hasWin(at: Cell(x: 4, y: 0), mark: .x, cells: cells, winLength: 5))
    }

    func testVerticalWin() {
        var cells: [Cell: Mark] = [:]
        for y in 0..<4 { cells[Cell(x: 2, y: y)] = .o }
        cells[Cell(x: 2, y: 4)] = .o
        XCTAssertTrue(WinChecker.hasWin(at: Cell(x: 2, y: 4), mark: .o, cells: cells, winLength: 5))
    }

    func testDiagonalWin() {
        var cells: [Cell: Mark] = [:]
        for i in 0..<3 {
            cells[Cell(x: i, y: i)] = .x
        }
        XCTAssertTrue(WinChecker.hasWin(at: Cell(x: 2, y: 2), mark: .x, cells: cells, winLength: 3))
    }

    func testNoWinYet() {
        var cells: [Cell: Mark] = [:]
        cells[Cell(x: 0, y: 0)] = .x
        cells[Cell(x: 1, y: 0)] = .x
        XCTAssertFalse(WinChecker.hasWin(at: Cell(x: 1, y: 0), mark: .x, cells: cells, winLength: 3))
    }

    func testWinThroughGap() {
        var cells: [Cell: Mark] = [:]
        cells[Cell(x: 0, y: 0)] = .x
        cells[Cell(x: 1, y: 0)] = .x
        cells[Cell(x: 3, y: 0)] = .x
        XCTAssertFalse(WinChecker.hasWin(at: Cell(x: 3, y: 0), mark: .x, cells: cells, winLength: 3))
    }
}
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
xcodebuild -scheme TacXO -destination 'platform=iOS Simulator,name=iPhone 16' test -only-testing:TacXOTests/WinCheckerTests
```

Expected: FAIL — `WinChecker` not found

- [ ] **Step 3: Implement WinChecker.swift**

```swift
import Foundation

enum WinChecker {
    private static let directions = [(1, 0), (0, 1), (1, 1), (1, -1)]

    static func hasWin(at cell: Cell, mark: Mark, cells: [Cell: Mark], winLength: Int) -> Bool {
        for (dx, dy) in directions {
            let count = 1
                + countDirection(from: cell, dx: dx, dy: dy, mark: mark, cells: cells)
                + countDirection(from: cell, dx: -dx, dy: -dy, mark: mark, cells: cells)
            if count >= winLength { return true }
        }
        return false
    }

    private static func countDirection(
        from cell: Cell,
        dx: Int,
        dy: Int,
        mark: Mark,
        cells: [Cell: Mark]
    ) -> Int {
        var count = 0
        var x = cell.x + dx
        var y = cell.y + dy
        while cells[Cell(x: x, y: y)] == mark {
            count += 1
            x += dx
            y += dy
        }
        return count
    }
}
```

- [ ] **Step 4: Run tests to verify they pass**

```bash
xcodebuild -scheme TacXO -destination 'platform=iOS Simulator,name=iPhone 16' test -only-testing:TacXOTests/WinCheckerTests
```

Expected: all 5 tests PASS

- [ ] **Step 5: Commit**

```bash
git add TacXO/Engine/WinChecker.swift TacXOTests/WinCheckerTests.swift
git commit -m "feat: add WinChecker with K-in-a-row detection"
```

---

### Task 4: GameEngine (TDD)

**Files:**
- Create: `TacXO/Engine/GameEngine.swift`
- Create: `TacXOTests/GameEngineTests.swift`

- [ ] **Step 1: Write failing tests**

```swift
import XCTest
@testable import TacXO

final class GameEngineTests: XCTestCase {
    func testXStartsFirst() {
        let engine = GameEngine(settings: GameSettings(winLength: 3, boardSize: .three, mode: .twoPlayer))
        XCTAssertEqual(engine.currentPlayer, .x)
    }

    func testValidMoveAlternatesTurn() throws {
        var engine = GameEngine(settings: GameSettings(winLength: 3, boardSize: .three, mode: .twoPlayer))
        let result = try engine.place(at: Cell(x: 0, y: 0))
        XCTAssertEqual(result, .ongoing)
        XCTAssertEqual(engine.currentPlayer, .o)
        XCTAssertEqual(engine.cells[Cell(x: 0, y: 0)], .x)
    }

    func testRejectsOccupiedCell() {
        var engine = GameEngine(settings: GameSettings(winLength: 3, boardSize: .three, mode: .twoPlayer))
        _ = try? engine.place(at: Cell(x: 1, y: 1))
        XCTAssertThrowsError(try engine.place(at: Cell(x: 1, y: 1)))
    }

    func testRejectsOutOfBoundsOnFixedBoard() {
        var engine = GameEngine(settings: GameSettings(winLength: 3, boardSize: .three, mode: .twoPlayer))
        XCTAssertThrowsError(try engine.place(at: Cell(x: 3, y: 0)))
    }

    func testDetectsWin() throws {
        var engine = GameEngine(settings: GameSettings(winLength: 3, boardSize: .three, mode: .twoPlayer))
        _ = try engine.place(at: Cell(x: 0, y: 0)) // x
        _ = try engine.place(at: Cell(x: 1, y: 0)) // o
        _ = try engine.place(at: Cell(x: 0, y: 1)) // x
        _ = try engine.place(at: Cell(x: 1, y: 1)) // o
        let result = try engine.place(at: Cell(x: 0, y: 2)) // x wins column
        XCTAssertEqual(result, .won(.x))
    }

    func testDetectsDrawOn3x3() throws {
        var engine = GameEngine(settings: GameSettings(winLength: 3, boardSize: .three, mode: .twoPlayer))
        let moves: [Cell] = [
            Cell(x: 0, y: 0), Cell(x: 0, y: 1),
            Cell(x: 1, y: 1), Cell(x: 0, y: 2),
            Cell(x: 2, y: 1), Cell(x: 1, y: 0),
            Cell(x: 1, y: 2), Cell(x: 2, y: 2),
            Cell(x: 2, y: 0)
        ]
        var last: GameResult = .ongoing
        for move in moves {
            last = try engine.place(at: move)
        }
        XCTAssertEqual(last, .draw)
    }

    func testResetClearsBoard() throws {
        var engine = GameEngine(settings: GameSettings(winLength: 3, boardSize: .three, mode: .twoPlayer))
        _ = try engine.place(at: Cell(x: 0, y: 0))
        engine.reset()
        XCTAssertTrue(engine.cells.isEmpty)
        XCTAssertEqual(engine.currentPlayer, .x)
    }

    func testInfiniteAllowsAnyCoordinate() throws {
        var engine = GameEngine(settings: GameSettings(winLength: 5, boardSize: .infinite, mode: .twoPlayer))
        let result = try engine.place(at: Cell(x: 100, y: -50))
        XCTAssertEqual(result, .ongoing)
    }
}
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
xcodebuild -scheme TacXO -destination 'platform=iOS Simulator,name=iPhone 16' test -only-testing:TacXOTests/GameEngineTests
```

Expected: FAIL — `GameEngine` not found

- [ ] **Step 3: Implement GameEngine.swift**

```swift
import Foundation

enum GameResult: Equatable {
    case ongoing
    case won(Mark)
    case draw
}

enum GameError: Error {
    case outOfBounds
    case cellOccupied
    case gameOver
}

struct GameEngine {
    let settings: GameSettings
    private(set) var cells: [Cell: Mark] = [:]
    private(set) var currentPlayer: Mark = .x
    private(set) var result: GameResult = .ongoing

    init(settings: GameSettings) {
        self.settings = settings
    }

    func canPlay(at cell: Cell) -> Bool {
        guard result == .ongoing else { return false }
        guard isInBounds(cell) else { return false }
        return cells[cell] == nil
    }

    mutating func place(at cell: Cell) throws -> GameResult {
        guard result == .ongoing else { throw GameError.gameOver }
        guard isInBounds(cell) else { throw GameError.outOfBounds }
        guard cells[cell] == nil else { throw GameError.cellOccupied }

        cells[cell] = currentPlayer

        if WinChecker.hasWin(at: cell, mark: currentPlayer, cells: cells, winLength: settings.winLength) {
            result = .won(currentPlayer)
            return result
        }

        if isDraw() {
            result = .draw
            return result
        }

        currentPlayer = currentPlayer.opponent
        return .ongoing
    }

    mutating func reset() {
        cells = [:]
        currentPlayer = .x
        result = .ongoing
    }

    private func isInBounds(_ cell: Cell) -> Bool {
        guard let dim = settings.boardSize.dimension else { return true }
        return (0..<dim).contains(cell.x) && (0..<dim).contains(cell.y)
    }

    private func isDraw() -> Bool {
        guard settings.boardSize.dimension != nil else { return false }
        guard let dim = settings.boardSize.dimension else { return false }
        return cells.count >= dim * dim
    }
}
```

- [ ] **Step 4: Run tests to verify they pass**

```bash
xcodebuild -scheme TacXO -destination 'platform=iOS Simulator,name=iPhone 16' test -only-testing:TacXOTests/GameEngineTests
```

Expected: all 8 tests PASS

- [ ] **Step 5: Commit**

```bash
git add TacXO/Engine/GameEngine.swift TacXOTests/GameEngineTests.swift
git commit -m "feat: add GameEngine with move validation and outcomes"
```

---

### Task 5: AdaptiveDifficulty (TDD)

**Files:**
- Create: `TacXO/AI/AdaptiveDifficulty.swift`
- Create: `TacXOTests/AdaptiveDifficultyTests.swift`

- [ ] **Step 1: Write failing tests**

```swift
import XCTest
@testable import TacXO

final class AdaptiveDifficultyTests: XCTestCase {
    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: "xo.neighbor.difficulty")
    }

    func testDefaultLevelIsFive() {
        let d = AdaptiveDifficulty()
        XCTAssertEqual(d.level, 5)
    }

    func testDecreaseOnLossFloorsAtZero() {
        var d = AdaptiveDifficulty()
        for _ in 0..<10 { d.recordLoss() }
        XCTAssertEqual(d.level, 0)
    }

    func testIncreaseOnWinCapsAtFive() {
        var d = AdaptiveDifficulty()
        d.recordLoss()
        d.recordLoss()
        for _ in 0..<10 { d.recordWin() }
        XCTAssertEqual(d.level, 5)
    }

    func testPersistsAcrossInstances() {
        var d = AdaptiveDifficulty()
        d.recordLoss()
        d.recordLoss()
        let d2 = AdaptiveDifficulty()
        XCTAssertEqual(d2.level, 3)
    }
}
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
xcodebuild -scheme TacXO -destination 'platform=iOS Simulator,name=iPhone 16' test -only-testing:TacXOTests/AdaptiveDifficultyTests
```

Expected: FAIL

- [ ] **Step 3: Implement AdaptiveDifficulty.swift**

```swift
import Foundation

struct AdaptiveDifficulty {
    private static let storageKey = "xo.neighbor.difficulty"
    private(set) var level: Int

    init() {
        if let stored = UserDefaults.standard.object(forKey: Self.storageKey) as? Int {
            level = stored
        } else {
            level = 5
            save()
        }
    }

    mutating func recordLoss() {
        level = max(0, level - 1)
        save()
    }

    mutating func recordWin() {
        level = min(5, level + 1)
        save()
    }

    private func save() {
        UserDefaults.standard.set(level, forKey: Self.storageKey)
    }
}
```

- [ ] **Step 4: Run tests to verify they pass**

```bash
xcodebuild -scheme TacXO -destination 'platform=iOS Simulator,name=iPhone 16' test -only-testing:TacXOTests/AdaptiveDifficultyTests
```

Expected: all 4 tests PASS

- [ ] **Step 5: Commit**

```bash
git add TacXO/AI/AdaptiveDifficulty.swift TacXOTests/AdaptiveDifficultyTests.swift
git commit -m "feat: add adaptive difficulty persistence for Neighbor AI"
```

---

### Task 6: AIPlayer (TDD)

**Files:**
- Create: `TacXO/AI/AIPlayer.swift`
- Create: `TacXOTests/AIPlayerTests.swift`

- [ ] **Step 1: Write failing tests**

```swift
import XCTest
@testable import TacXO

final class AIPlayerTests: XCTestCase {
    func testTakesWinningMoveOn3x3() {
        var engine = GameEngine(settings: GameSettings(winLength: 3, boardSize: .three, mode: .vsNeighbor))
        _ = try? engine.place(at: Cell(x: 0, y: 0)) // human x
        _ = try? engine.place(at: Cell(x: 1, y: 0)) // ai o
        _ = try? engine.place(at: Cell(x: 2, y: 1)) // human x
        _ = try? engine.place(at: Cell(x: 0, y: 1)) // ai o
        _ = try? engine.place(at: Cell(x: 1, y: 2)) // human x — threat diagonal

        let move = AIPlayer.bestMove(for: engine, difficulty: 5)
        XCTAssertEqual(move, Cell(x: 1, y: 1)) // ai blocks
    }

    func testTakesImmediateWin() {
        var engine = GameEngine(settings: GameSettings(winLength: 3, boardSize: .three, mode: .vsNeighbor))
        engine.cells = [
            Cell(x: 0, y: 0): .o,
            Cell(x: 1, y: 0): .o,
            Cell(x: 0, y: 1): .x
        ]
        engine.currentPlayer = .o
        let move = AIPlayer.bestMove(for: engine, difficulty: 5)
        XCTAssertEqual(move, Cell(x: 2, y: 0))
    }

    func testReturnsValidMoveAtLowDifficulty() {
        var engine = GameEngine(settings: GameSettings(winLength: 3, boardSize: .three, mode: .vsNeighbor))
        let move = AIPlayer.bestMove(for: engine, difficulty: 0)
        XCTAssertTrue(engine.canPlay(at: move))
    }
}
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
xcodebuild -scheme TacXO -destination 'platform=iOS Simulator,name=iPhone 16' test -only-testing:TacXOTests/AIPlayerTests
```

Expected: FAIL

- [ ] **Step 3: Implement AIPlayer.swift**

```swift
import Foundation

enum AIPlayer {
    static func bestMove(for engine: GameEngine, difficulty: Int) -> Cell {
        let candidates = candidateCells(for: engine)
        guard !candidates.isEmpty else {
            return Cell(x: 0, y: 0)
        }

        let ranked = rankMoves(candidates, engine: engine)
        let chosen = selectMove(from: ranked, difficulty: difficulty)
        return chosen
    }

    private static func candidateCells(for engine: GameEngine) -> [Cell] {
        if let dim = engine.settings.boardSize.dimension {
            return allCellsInBounds(dimension: dim).filter { engine.canPlay(at: $0) }
        }
        return localCandidates(engine: engine)
    }

    private static func allCellsInBounds(dimension: Int) -> [Cell] {
        (0..<dimension).flatMap { y in
            (0..<dimension).map { x in Cell(x: x, y: y) }
        }
    }

    private static func localCandidates(engine: GameEngine) -> [Cell] {
        guard !engine.cells.isEmpty else {
            return (0..<7).flatMap { y in (0..<7).map { x in Cell(x: x, y: y) } }
        }
        var set = Set<Cell>()
        for (cell, _) in engine.cells {
            for dx in -2...2 {
                for dy in -2...2 {
                    let c = Cell(x: cell.x + dx, y: cell.y + dy)
                    if engine.canPlay(at: c) { set.insert(c) }
                }
            }
        }
        return Array(set)
    }

    private static func rankMoves(_ moves: [Cell], engine: GameEngine) -> [(Cell, Int)] {
        moves.map { cell in
            (cell, score(move: cell, engine: engine))
        }
        .sorted { $0.1 > $1.1 }
    }

    private static func score(move: Cell, engine: GameEngine) -> Int {
        var copy = engine
        guard (try? copy.place(at: move)) != nil else { return Int.min }
        switch copy.result {
        case .won(let mark) where mark == engine.currentPlayer:
            return 10_000
        default:
            break
        }
        // Block opponent win
        var opponentCopy = engine
        opponentCopy.currentPlayer = engine.currentPlayer.opponent
        if let block = immediateWinningMove(for: opponentCopy) {
            if block == move { return 5_000 }
        }
        return heuristic(move: move, engine: engine)
    }

    private static func immediateWinningMove(for engine: GameEngine) -> Cell? {
        let moves = candidateCells(for: engine)
        for move in moves {
            var copy = engine
            if let result = try? copy.place(at: move), result == .won(engine.currentPlayer) {
                return move
            }
        }
        return nil
    }

    private static func heuristic(move: Cell, engine: GameEngine) -> Int {
        var copy = engine
        _ = try? copy.place(at: move)
        let centerBias = engine.settings.boardSize.dimension.map { dim in
            let cx = Double(dim - 1) / 2
            let cy = cx
            let dist = abs(Double(move.x) - cx) + abs(Double(move.y) - cy)
            return Int(10 - dist)
        } ?? 0
        return centerBias
    }

    private static func selectMove(from ranked: [(Cell, Int)], difficulty: Int) -> Cell {
        guard let best = ranked.first?.0 else { return Cell(x: 0, y: 0) }
        let top = ranked.prefix(3).map(\.0)
        switch difficulty {
        case 5: return best
        case 4: return ranked.prefix(2).randomElement()?.0 ?? best
        case 3: return Double.random(in: 0...1) < 0.2 ? (ranked.dropFirst().first?.0 ?? best) : best
        case 2: return Double.random(in: 0...1) < 0.5 ? (ranked.dropFirst().first?.0 ?? best) : best
        case 1: return top.randomElement() ?? best
        default: return top.randomElement() ?? best
        }
    }
}
```

- [ ] **Step 4: Run tests to verify they pass**

```bash
xcodebuild -scheme TacXO -destination 'platform=iOS Simulator,name=iPhone 16' test -only-testing:TacXOTests/AIPlayerTests
```

Expected: all 3 tests PASS

- [ ] **Step 5: Commit**

```bash
git add TacXO/AI/AIPlayer.swift TacXOTests/AIPlayerTests.swift
git commit -m "feat: add AIPlayer with threat detection and difficulty mixing"
```

---

### Task 7: Neighbor personality (quotes + sound)

**Files:**
- Create: `TacXO/Personality/NeighborQuotes.swift`
- Create: `TacXO/Personality/SoundManager.swift`
- Create: `TacXO/Resources/place.wav` (short scratch — generate or record <1s)
- Create: `TacXO/Resources/neighbor_loss_1.wav`, `neighbor_loss_2.wav`, `neighbor_loss_3.wav`

- [ ] **Step 1: Create NeighborQuotes.swift**

```swift
import Foundation

enum NeighborQuotes {
    static let all: [String] = [
        "My dead dog plays better.",
        "You call that thinking?",
        "Back in my day we had brains.",
        "I've seen fence posts smarter than you.",
        "Keep practicing. You'll get worse.",
        "That move smelled funny. Like you.",
        "Did your mom teach you that?",
        "Ha! Kids these days.",
        "You bored me to death.",
        "Even my lawn gnome would win.",
        "Try using your head next time.",
        "Pathetic. Truly pathetic.",
        "I almost felt sorry. Almost.",
        "You play like my arthritic uncle.",
        "Go back to kindergarten.",
        "Was that on purpose? Hope not.",
        "My garbage plays harder than you.",
        "You make losing look easy.",
        "I've had better naps than this game.",
        "Stick to hopscotch, kid."
    ]

    static func random() -> String {
        all.randomElement() ?? "Ha!"
    }
}
```

- [ ] **Step 2: Create SoundManager.swift**

```swift
import AVFoundation
import UIKit

final class SoundManager {
    static let shared = SoundManager()

    private var players: [String: AVAudioPlayer] = [:]

    private init() {
        try? AVAudioSession.sharedInstance().setCategory(.ambient)
        try? AVAudioSession.sharedInstance().setActive(true)
        preload("place")
        preload("neighbor_loss_1")
        preload("neighbor_loss_2")
        preload("neighbor_loss_3")
    }

    func playPlace() {
        play("place")
        lightHaptic()
    }

    func playNeighborLoss() {
        let index = Int.random(in: 1...3)
        play("neighbor_loss_\(index)")
        errorHaptic()
    }

    func playWin() {
        successHaptic()
    }

    private func preload(_ name: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: "wav") else { return }
        players[name] = try? AVAudioPlayer(contentsOf: url)
        players[name]?.prepareToPlay()
    }

    private func play(_ name: String) {
        players[name]?.currentTime = 0
        players[name]?.play()
    }

    private func lightHaptic() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    private func errorHaptic() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }

    private func successHaptic() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}
```

- [ ] **Step 3: Add placeholder audio files**

Generate 4 short silent/near-silent WAV files (<0.5s) and add to `TacXO/Resources/`. Ensure they are in the **Copy Bundle Resources** build phase.

If no audio tooling available, record 0.1s silence via:

```bash
cd TacXO/Resources
ffmpeg -f lavfi -i anullsrc=r=44100:cl=mono -t 0.2 -q:a 9 -acodec libmp3lame place.wav 2>/dev/null || \
  python3 -c "import wave,struct; w=wave.open('place.wav','w'); w.setnchannels(1); w.setsampwidth(2); w.setframerate(44100); w.writeframes(struct.pack('<h',0)*1000); w.close()"
# Copy place.wav to neighbor_loss_1.wav, neighbor_loss_2.wav, neighbor_loss_3.wav
```

Replace with real SFX before App Store submission.

- [ ] **Step 4: Build**

```bash
xcodebuild -scheme TacXO -destination 'platform=iOS Simulator,name=iPhone 16' build
```

Expected: `BUILD SUCCEEDED`

- [ ] **Step 5: Commit**

```bash
git add TacXO/Personality/ TacXO/Resources/
git commit -m "feat: add Neighbor quotes and SoundManager with placeholder SFX"
```

---

### Task 8: GameController

**Files:**
- Create: `TacXO/ViewModels/GameController.swift`

- [ ] **Step 1: Implement GameController.swift**

```swift
import Foundation
import Observation

@Observable
final class GameController {
    var settings: GameSettings
    private(set) var engine: GameEngine
    private(set) var difficulty = AdaptiveDifficulty()
    var lossQuote: String?
    var showLossOverlay = false

    /// Human is always X; Neighbor is O in vs Neighbor mode
    var isHumanTurn: Bool {
        settings.mode == .twoPlayer || engine.currentPlayer == .x
    }

    init(settings: GameSettings = .load()) {
        self.settings = settings
        self.engine = GameEngine(settings: settings)
    }

    func applySettings(_ newSettings: GameSettings) {
        settings = newSettings
        settings.save()
        newGame()
    }

    func newGame() {
        engine = GameEngine(settings: settings)
        lossQuote = nil
        showLossOverlay = false
    }

    func tap(cell: Cell) {
        guard engine.result == .ongoing else { return }
        guard isHumanTurn else { return }
        guard engine.canPlay(at: cell) else { return }

        performMove(at: cell)

        if settings.mode == .vsNeighbor, engine.result == .ongoing {
            let aiMove = AIPlayer.bestMove(for: engine, difficulty: difficulty.level)
            performMove(at: aiMove)
        }
    }

    private func performMove(at cell: Cell) {
        guard let result = try? engine.place(at: cell) else { return }
        SoundManager.shared.playPlace()

        switch result {
        case .won(let mark):
            handleGameEnd(winner: mark)
        case .draw:
            break
        case .ongoing:
            break
        }
    }

    private func handleGameEnd(winner: Mark) {
        if settings.mode == .vsNeighbor {
            if winner == .x {
                difficulty.recordWin()
                SoundManager.shared.playWin()
            } else {
                difficulty.recordLoss()
                lossQuote = NeighborQuotes.random()
                showLossOverlay = true
                SoundManager.shared.playNeighborLoss()
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                    self?.showLossOverlay = false
                }
            }
        }
    }
}
```

- [ ] **Step 2: Build**

```bash
xcodebuild -scheme TacXO -destination 'platform=iOS Simulator,name=iPhone 16' build
```

Expected: `BUILD SUCCEEDED`

- [ ] **Step 3: Commit**

```bash
git add TacXO/ViewModels/GameController.swift
git commit -m "feat: add GameController wiring engine, AI, and neighbor loss flow"
```

---

### Task 9: Board UI (CellView + BoardView)

**Files:**
- Create: `TacXO/Views/CellView.swift`
- Create: `TacXO/Views/BoardView.swift`

- [ ] **Step 1: Create CellView.swift**

```swift
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
```

- [ ] **Step 2: Create BoardView.swift**

```swift
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
```

- [ ] **Step 3: Build**

```bash
xcodebuild -scheme TacXO -destination 'platform=iOS Simulator,name=iPhone 16' build
```

Expected: `BUILD SUCCEEDED`

- [ ] **Step 4: Commit**

```bash
git add TacXO/Views/CellView.swift TacXO/Views/BoardView.swift
git commit -m "feat: add paper-style board and cell views"
```

---

### Task 10: Play screen + loss overlay

**Files:**
- Create: `TacXO/Views/LossOverlayView.swift`
- Create: `TacXO/Views/PlayView.swift`

- [ ] **Step 1: Create LossOverlayView.swift**

```swift
import SwiftUI

struct LossOverlayView: View {
    let quote: String

    var body: some View {
        ZStack {
            Color.black.opacity(0.35)
                .ignoresSafeArea()
            Text(quote)
                .font(.system(.title3, design: .serif))
                .multilineTextAlignment(.center)
                .padding(24)
                .background(Color(red: 0.98, green: 0.96, blue: 0.9))
                .cornerRadius(8)
                .shadow(radius: 4)
                .padding(32)
        }
    }
}
```

- [ ] **Step 2: Create PlayView.swift**

```swift
import SwiftUI

struct PlayView: View {
    @Bindable var controller: GameController
    @State private var showSettings = false

    var body: some View {
        ZStack {
            Color(red: 0.98, green: 0.96, blue: 0.9)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                HStack {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                            .font(.title2)
                    }
                    Spacer()
                    Text(turnLabel)
                        .font(.system(.headline, design: .serif))
                }
                .padding(.horizontal)

                BoardView(engine: controller.engine) { cell in
                    controller.tap(cell: cell)
                }

                if controller.engine.result != .ongoing {
                    Text(gameOverLabel)
                        .font(.system(.title3, design: .serif))
                }

                Button("New Game") {
                    controller.newGame()
                }
                .font(.system(.body, design: .serif))
                .padding(.bottom)
            }

            if controller.showLossOverlay, let quote = controller.lossQuote {
                LossOverlayView(quote: quote)
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(controller: controller)
        }
    }

    private var turnLabel: String {
        switch controller.engine.result {
        case .ongoing:
            return "\(controller.engine.currentPlayer.label)'s turn"
        case .won(let mark):
            return "\(mark.label) wins!"
        case .draw:
            return "Draw"
        }
    }

    private var gameOverLabel: String {
        switch controller.engine.result {
        case .won(let mark): return "\(mark.label) wins!"
        case .draw: return "Draw — even garbage ties sometimes."
        case .ongoing: return ""
        }
    }
}
```

- [ ] **Step 3: Build**

```bash
xcodebuild -scheme TacXO -destination 'platform=iOS Simulator,name=iPhone 16' build
```

Expected: `BUILD SUCCEEDED`

- [ ] **Step 4: Commit**

```bash
git add TacXO/Views/LossOverlayView.swift TacXO/Views/PlayView.swift
git commit -m "feat: add PlayView with turn display and loss overlay"
```

---

### Task 11: Settings screen

**Files:**
- Create: `TacXO/Views/SettingsView.swift`

- [ ] **Step 1: Create SettingsView.swift**

```swift
import SwiftUI

struct SettingsView: View {
    @Bindable var controller: GameController
    @Environment(\.dismiss) private var dismiss
    @State private var draft: GameSettings

    init(controller: GameController) {
        self.controller = controller
        _draft = State(initialValue: controller.settings)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Win Length") {
                    Stepper(value: $draft.winLength, in: 3...7) {
                        Text("\(draft.winLength) in a row")
                    }
                }
                Section("Board Size") {
                    Picker("Board", selection: $draft.boardSize) {
                        ForEach(BoardSize.allCases) { size in
                            Text(size.rawValue).tag(size)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                Section("Mode") {
                    Picker("Mode", selection: $draft.mode) {
                        ForEach(GameMode.allCases) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        controller.applySettings(draft)
                        dismiss()
                    }
                }
            }
        }
    }
}
```

- [ ] **Step 2: Build**

```bash
xcodebuild -scheme TacXO -destination 'platform=iOS Simulator,name=iPhone 16' build
```

Expected: `BUILD SUCCEEDED`

- [ ] **Step 3: Commit**

```bash
git add TacXO/Views/SettingsView.swift
git commit -m "feat: add SettingsView for rules configuration"
```

---

### Task 12: App entry + final wiring

**Files:**
- Modify: `TacXO/TacXOApp.swift`

- [ ] **Step 1: Wire TacXOApp.swift**

```swift
import SwiftUI

@main
struct TacXOApp: App {
    @State private var controller = GameController()

    var body: some Scene {
        WindowGroup {
            PlayView(controller: controller)
                .onAppear {
                    _ = SoundManager.shared
                }
        }
    }
}
```

- [ ] **Step 2: Run full test suite**

```bash
xcodebuild -scheme TacXO -destination 'platform=iOS Simulator,name=iPhone 16' test
```

Expected: all TacXOTests PASS

- [ ] **Step 3: Run app in simulator**

```bash
xcodebuild -scheme TacXO -destination 'platform=iOS Simulator,name=iPhone 16' build
open -a Simulator
# Install and launch via Xcode Run (⌘R) or:
xcrun simctl boot "iPhone 16" 2>/dev/null || true
xcodebuild -scheme TacXO -destination 'platform=iOS Simulator,name=iPhone 16' -derivedDataPath build build
xcrun simctl install booted build/Build/Products/Debug-iphonesimulator/TacXO.app
xcrun simctl launch booted com.tacxo.game
```

Manual smoke test:
1. App opens to board — no onboarding
2. Place marks in 3×3 — win detected
3. Settings → change to vs Neighbor → AI responds
4. Lose on purpose — quote overlay + haptic
5. Settings persist after kill/relaunch

- [ ] **Step 4: Commit**

```bash
git add TacXO/TacXOApp.swift
git commit -m "feat: wire app entry to PlayView and complete v1 flow"
```

---

## Spec Coverage Checklist

| Spec requirement | Task |
|------------------|------|
| SwiftUI + Swift, iOS 17+ | Task 1 |
| Win length 3–7, default 5 | Task 2, 11 |
| Board sizes incl. infinite | Task 2, 4, 9 |
| 2-player pass-and-play | Task 8, 10 |
| vs Neighbor adaptive AI | Task 5, 6, 8 |
| Toxic quotes on loss | Task 7, 10 |
| Paper SFX + haptics | Task 7 |
| Settings persistence | Task 2, 11 |
| Unit tests engine/AI | Tasks 3–6 |
| iPhone portrait, 2 screens | Tasks 10–12 |
| No dark mode / online / stats | Omitted by design |

## Out of Scope (do not implement in this plan)

- iPad layout, pinch-zoom, localization, App Store assets, real audio recording sessions

---
