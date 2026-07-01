# Nearby PvP Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add settings-driven nearby PvP using communication-kit MPC so two iPhones can host/join and play tic-tac-toe with pause-on-disconnect.

**Architecture:** Third `GameMode.nearbyPvP` + `NearbyRole` in Settings; `NearbyGameController` orchestrates lobby/board phases on existing `PlayView`; `NearbyGameService` wraps `CommunicationEngine` (host-authoritative moves); `NearbyPeerBrowser` lists MPC advertisers for joiners.

**Tech Stack:** Swift 5.9+, SwiftUI, iOS 17+, communication-kit (`ComunicationCore`, `ComunicationMPC`), MultipeerConnectivity, XCTest, XcodeGen

**Spec:** `docs/superpowers/specs/2026-07-01-nearby-pvp-design.md`

---

## File Map

| File | Responsibility |
|------|----------------|
| `project.yml` | SPM package + Info.plist local network keys |
| `TacXO/Networking/AppIdentity.swift` | Keychain-backed `ParticipantID` |
| `TacXO/Networking/TransferService.swift` | Engine init, MPC register, start/stop |
| `TacXO/Networking/NearbyGameMessage.swift` | Codable messages + `NearbyGameState` |
| `TacXO/Networking/NearbyPeerBrowser.swift` | `MCNearbyServiceBrowser` → `[DiscoveredHost]` |
| `TacXO/Networking/NearbyGameService.swift` | Host/join/session, send/receive |
| `TacXO/ViewModels/NearbyGameController.swift` | Phase machine, engine sync, tap handling |
| `TacXO/Views/NearbyWaitingView.swift` | Host waiting room |
| `TacXO/Views/NearbyBrowseView.swift` | Join list |
| `TacXO/Views/NearbyPauseOverlay.swift` | Pause + forfeit |
| `TacXO/Models/GameSettings.swift` | `nearbyPvP`, `NearbyRole` |
| `TacXO/Engine/GameEngine.swift` | `GameResult: Codable` |
| `TacXO/Views/SettingsView.swift` | Mode + role UI |
| `TacXO/Views/PlayView.swift` | Phase-based content switch |
| `TacXO/TacXOApp.swift` | Wire services at launch |
| `TacXO/Resources/Localizable.xcstrings` | New strings |
| `TacXOTests/NearbyGameMessageTests.swift` | Wire protocol tests |
| `TacXOTests/NearbyGameControllerTests.swift` | Host validation tests |
| `PRIVACY.md` | Local network disclosure |

---

### Task 1: Add communication-kit SPM dependency

**Files:**
- Modify: `project.yml`
- Modify: `TacXO.xcodeproj` (regenerate via XcodeGen)

- [ ] **Step 1: Add package and products to `project.yml`**

Add at top level:

```yaml
packages:
  comunication:
    url: https://github.com/milky-way-66/communication-kit.git
    from: 0.1.0
```

Under `targets.TacXO`, add:

```yaml
    dependencies:
      - package: comunication
        product: ComunicationCore
      - package: comunication
        product: ComunicationMPC
```

Under `targets.TacXO.settings.base`, add Info.plist keys:

```yaml
        INFOPLIST_KEY_NSLocalNetworkUsageDescription: "TacXO uses the local network to find nearby players and sync moves during PvP games."
        INFOPLIST_KEY_NSBonjourServices:
          - _tacxo-pvp._tcp
```

- [ ] **Step 2: Regenerate Xcode project**

```bash
cd /Users/khang/work/side-project/xo
xcodegen generate
```

Expected: `TacXO.xcodeproj` updated with package references.

- [ ] **Step 3: Resolve packages and build**

```bash
xcodebuild -scheme TacXO -destination 'generic/platform=iOS' build
```

Expected: `BUILD SUCCEEDED` (may take longer first time while resolving SPM).

- [ ] **Step 4: Commit**

```bash
git add project.yml TacXO.xcodeproj
git commit -m "chore: add communication-kit SPM for nearby PvP"
```

---

### Task 2: Codable game result and wire protocol

**Files:**
- Modify: `TacXO/Engine/GameEngine.swift`
- Create: `TacXO/Networking/NearbyGameMessage.swift`
- Create: `TacXOTests/NearbyGameMessageTests.swift`

- [ ] **Step 1: Write failing tests**

Create `TacXOTests/NearbyGameMessageTests.swift`:

```swift
import XCTest
@testable import TacXO

final class NearbyGameMessageTests: XCTestCase {
    func testGameResultRoundTrip() throws {
        let results: [GameResult] = [.ongoing, .won(.x), .won(.o), .draw]
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        for result in results {
            let data = try encoder.encode(result)
            let decoded = try decoder.decode(GameResult.self, from: data)
            XCTAssertEqual(decoded, result)
        }
    }

    func testNearbyGameStateRoundTrip() throws {
        let state = NearbyGameState(
            cells: [Cell(x: 0, y: 0): .x, Cell(x: 1, y: 1): .o],
            currentPlayer: .x,
            result: .ongoing,
            winningCells: []
        )
        let data = try JSONEncoder().encode(state)
        let decoded = try JSONDecoder().decode(NearbyGameState.self, from: data)
        XCTAssertEqual(decoded, state)
    }

    func testInviteRoundTrip() throws {
        var settings = GameSettings.default
        settings.boardSize = .five
        settings.winLength = 5
        let invite = GameInvite(settings: settings, hostParticipantID: "host-abc")
        let message = NearbyGameMessage.invite(invite)
        let data = try JSONEncoder().encode(message)
        let decoded = try JSONDecoder().decode(NearbyGameMessage.self, from: data)
        XCTAssertEqual(decoded, message)
    }
}
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
cd /Users/khang/work/side-project/xo
xcodebuild test -scheme TacXO -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:TacXOTests/NearbyGameMessageTests 2>&1 | tail -20
```

Expected: FAIL — types not found.

- [ ] **Step 3: Add `Codable` to `GameResult`**

In `TacXO/Engine/GameEngine.swift`, change:

```swift
enum GameResult: Equatable, Codable {
    case ongoing
    case won(Mark)
    case draw

    private enum CodingKeys: String, CodingKey { case kind, mark }

    private enum Kind: String, Codable { case ongoing, won, draw }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        switch try c.decode(Kind.self, forKey: .kind) {
        case .ongoing: self = .ongoing
        case .won: self = .won(try c.decode(Mark.self, forKey: .mark))
        case .draw: self = .draw
        }
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .ongoing: try c.encode(Kind.ongoing, forKey: .kind)
        case .won(let mark):
            try c.encode(Kind.won, forKey: .kind)
            try c.encode(mark, forKey: .mark)
        case .draw: try c.encode(Kind.draw, forKey: .kind)
        }
    }
}
```

- [ ] **Step 4: Create `TacXO/Networking/NearbyGameMessage.swift`**

```swift
import Foundation

struct GameInvite: Codable, Equatable {
    let settings: GameSettings
    let hostParticipantID: String
}

struct NearbyGameState: Codable, Equatable {
    let cells: [Cell: Mark]
    let currentPlayer: Mark
    let result: GameResult
    let winningCells: Set<Cell>

    init(cells: [Cell: Mark], currentPlayer: Mark, result: GameResult, winningCells: Set<Cell>) {
        self.cells = cells
        self.currentPlayer = currentPlayer
        self.result = result
        self.winningCells = winningCells
    }

    init(engine: GameEngine) {
        self.cells = engine.cells
        self.currentPlayer = engine.currentPlayer
        self.result = engine.result
        self.winningCells = engine.winningCells
    }
}

enum NearbyGameMessage: Codable, Equatable {
    case invite(GameInvite)
    case moveRequest(Cell)
    case gameState(NearbyGameState)
    case forfeit
    case rematchRequest
    case rematchAccepted(GameInvite)

    private enum CodingKeys: String, CodingKey { case type, invite, cell, state }

    private enum MessageType: String, Codable {
        case invite, moveRequest, gameState, forfeit, rematchRequest, rematchAccepted
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        switch try c.decode(MessageType.self, forKey: .type) {
        case .invite:
            self = .invite(try c.decode(GameInvite.self, forKey: .invite))
        case .moveRequest:
            self = .moveRequest(try c.decode(Cell.self, forKey: .cell))
        case .gameState:
            self = .gameState(try c.decode(NearbyGameState.self, forKey: .state))
        case .forfeit:
            self = .forfeit
        case .rematchRequest:
            self = .rematchRequest
        case .rematchAccepted:
            self = .rematchAccepted(try c.decode(GameInvite.self, forKey: .invite))
        }
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .invite(let invite):
            try c.encode(MessageType.invite, forKey: .type)
            try c.encode(invite, forKey: .invite)
        case .moveRequest(let cell):
            try c.encode(MessageType.moveRequest, forKey: .type)
            try c.encode(cell, forKey: .cell)
        case .gameState(let state):
            try c.encode(MessageType.gameState, forKey: .type)
            try c.encode(state, forKey: .state)
        case .forfeit:
            try c.encode(MessageType.forfeit, forKey: .type)
        case .rematchRequest:
            try c.encode(MessageType.rematchRequest, forKey: .type)
        case .rematchAccepted(let invite):
            try c.encode(MessageType.rematchAccepted, forKey: .type)
            try c.encode(invite, forKey: .invite)
        }
    }
}
```

- [ ] **Step 5: Run tests to verify they pass**

```bash
xcodebuild test -scheme TacXO -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:TacXOTests/NearbyGameMessageTests 2>&1 | tail -20
```

Expected: all tests PASS.

- [ ] **Step 6: Commit**

```bash
git add TacXO/Engine/GameEngine.swift TacXO/Networking/NearbyGameMessage.swift TacXOTests/NearbyGameMessageTests.swift
git commit -m "feat: add nearby PvP wire protocol and Codable GameResult"
```

---

### Task 3: Extend GameSettings with nearby mode and role

**Files:**
- Modify: `TacXO/Models/GameSettings.swift`
- Modify: `TacXO/Resources/Localizable.xcstrings`

- [ ] **Step 1: Add enums and field**

In `GameSettings.swift`:

```swift
enum NearbyRole: String, Codable, CaseIterable, Identifiable {
    case host
    case join

    var id: String { rawValue }

    var labelKey: String {
        switch self {
        case .host: return "nearby_role_host"
        case .join: return "nearby_role_join"
        }
    }
}
```

Add to `GameMode`:

```swift
case nearbyPvP

// in labelKey:
case .nearbyPvP: return "mode_nearby_pvp"
```

Add to `GameSettings`:

```swift
var nearbyRole: NearbyRole = .host
```

Update `GameMode` decoder to accept `"nearbyPvP"` / `"PvP Nearby"`.

- [ ] **Step 2: Add localized strings**

In `Localizable.xcstrings`, add keys:

- `mode_nearby_pvp` — EN: "PvP Nearby", VI: "PvP gần"
- `nearby_role_section` — EN: "Role", VI: "Vai trò"
- `nearby_role_host` — EN: "Host", VI: "Chủ phòng"
- `nearby_role_join` — EN: "Join", VI: "Tham gia"

- [ ] **Step 3: Build**

```bash
xcodebuild -scheme TacXO -destination 'generic/platform=iOS' build 2>&1 | tail -5
```

Expected: `BUILD SUCCEEDED`.

- [ ] **Step 4: Commit**

```bash
git add TacXO/Models/GameSettings.swift TacXO/Resources/Localizable.xcstrings
git commit -m "feat: add nearby PvP mode and host/join role to settings"
```

---

### Task 4: AppIdentity and TransferService

**Files:**
- Create: `TacXO/Networking/AppIdentity.swift`
- Create: `TacXO/Networking/TransferService.swift`

- [ ] **Step 1: Create `AppIdentity.swift`**

```swift
import ComunicationCore
import Foundation
import Security

struct AppIdentity: IdentityPort {
    private static let keychainKey = "com.xo.game.participantID"

    var currentParticipantID: ParticipantID {
        get async {
            ParticipantID(Self.loadOrCreateID())
        }
    }

    private static func loadOrCreateID() -> String {
        if let existing = readKeychain() { return existing }
        let newID = UUID().uuidString
        saveKeychain(newID)
        return newID
    }

    private static func readKeychain() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: keychainKey,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var item: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess,
              let data = item as? Data,
              let string = String(data: data, encoding: .utf8) else { return nil }
        return string
    }

    private static func saveKeychain(_ value: String) {
        let data = Data(value.utf8)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: keychainKey,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }
}
```

- [ ] **Step 2: Create `TransferService.swift`**

```swift
import ComunicationCore
import ComunicationMPC
import Foundation
import UIKit

@MainActor
final class TransferService: ObservableObject {
    static let serviceType = "tacxo-pvp"

    let engine: CommunicationEngine

    init() throws {
        engine = try CommunicationEngine(
            configuration: .init(mpcDiscoveryTimeout: 8),
            identity: AppIdentity()
        )
    }

    func registerMPC(displayName: String, discoveryInfo: [String: String]) {
        engine.register(transport: MPCTransportAdapter(
            serviceType: Self.serviceType,
            displayName: displayName,
            discoveryInfo: discoveryInfo
        ))
    }

    func start() async throws {
        try await engine.start()
    }

    func stop() async {
        await engine.stop()
    }
}
```

- [ ] **Step 3: Build**

```bash
xcodebuild -scheme TacXO -destination 'generic/platform=iOS' build 2>&1 | tail -5
```

Expected: `BUILD SUCCEEDED`.

- [ ] **Step 4: Commit**

```bash
git add TacXO/Networking/AppIdentity.swift TacXO/Networking/TransferService.swift
git commit -m "feat: add TransferService and AppIdentity for MPC"
```

---

### Task 5: NearbyPeerBrowser for join list

**Files:**
- Create: `TacXO/Networking/NearbyPeerBrowser.swift`

- [ ] **Step 1: Implement browser**

```swift
import Foundation
import MultipeerConnectivity

struct DiscoveredHost: Identifiable, Equatable {
    let id: String           // participantID from discoveryInfo
    let displayName: String
    let boardSize: BoardSize
    let winLength: Int
    let peerID: MCPeerID
}

@MainActor
final class NearbyPeerBrowser: NSObject, ObservableObject {
    @Published private(set) var hosts: [DiscoveredHost] = []

    private let serviceType: String
    private var browser: MCNearbyServiceBrowser?
    private var peerMap: [String: MCPeerID] = [:]

    init(serviceType: String) {
        self.serviceType = serviceType
        super.init()
    }

    func start() {
        stop()
        let browser = MCNearbyServiceBrowser(peer: MCPeerID(displayName: UIDevice.current.name), serviceType: serviceType)
        browser.delegate = self
        browser.startBrowsingForPeers()
        self.browser = browser
        hosts = []
        peerMap = [:]
    }

    func stop() {
        browser?.stopBrowsingForPeers()
        browser = nil
        hosts = []
        peerMap = [:]
    }

    func peerID(for host: DiscoveredHost) -> MCPeerID {
        host.peerID
    }
}

extension NearbyPeerBrowser: MCNearbyServiceBrowserDelegate {
    nonisolated func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
        Task { @MainActor in
            guard let info,
                  let participantID = info["participantID"],
                  let boardRaw = info["boardSize"],
                  let boardSize = BoardSize(rawValue: boardRaw) ?? BoardSize.allCases.first(where: { $0.dimension == Int(boardRaw) }),
                  let winLength = Int(info["winLength"] ?? "") else { return }
            peerMap[participantID] = peerID
            let host = DiscoveredHost(
                id: participantID,
                displayName: peerID.displayName,
                boardSize: boardSize,
                winLength: winLength,
                peerID: peerID
            )
            if !hosts.contains(where: { $0.id == participantID }) {
                hosts.append(host)
            }
        }
    }

    nonisolated func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        Task { @MainActor in
            hosts.removeAll { $0.peerID == peerID }
            peerMap = peerMap.filter { $0.value != peerID }
        }
    }
}
```

Add `import UIKit` at top for `UIDevice`.

Store `boardSize` in discoveryInfo as `BoardSize.rawValue` (e.g. `"5×5"`).

- [ ] **Step 2: Build and commit**

```bash
xcodebuild -scheme TacXO -destination 'generic/platform=iOS' build 2>&1 | tail -5
git add TacXO/Networking/NearbyPeerBrowser.swift
git commit -m "feat: add NearbyPeerBrowser for join game list"
```

---

### Task 6: NearbyGameService

**Files:**
- Create: `TacXO/Networking/NearbyGameService.swift`

- [ ] **Step 1: Implement service**

Core responsibilities:

- `startHosting(settings:participantID:)` — register MPC with discoveryInfo, `createChannel`, send `.invite`
- `startBrowsing()` — delegate to `NearbyPeerBrowser`
- `join(host:localParticipantID:)` — `createChannel` with host participant, wait for `.invite` / `.gameState`
- `send(_ message:)` — `engine.send(message, in: channelID)`
- `observeMessages()` — `AsyncStream<NearbyGameMessage>` from `itemUpdates`
- `stop()` — stop browser, `engine.stop()` path via TransferService
- Track `channelID: UUID?`, `isHost: Bool`, `isConnected: Bool`

Host discoveryInfo keys when registering MPC:

```swift
[
    "participantID": participantID,
    "boardSize": settings.boardSize.rawValue,
    "winLength": "\(settings.winLength)"
]
```

Decode incoming items:

```swift
private func decodeMessage(from item: TransferItem) -> NearbyGameMessage? {
    switch item.payload {
    case .json(let data):
        return try? JSONDecoder().decode(NearbyGameMessage.self, from: data)
    default:
        return nil
    }
}
```

- [ ] **Step 2: Build and commit**

```bash
xcodebuild -scheme TacXO -destination 'generic/platform=iOS' build 2>&1 | tail -5
git add TacXO/Networking/NearbyGameService.swift
git commit -m "feat: add NearbyGameService for host/join sessions"
```

---

### Task 7: NearbyGameController

**Files:**
- Create: `TacXO/ViewModels/NearbyGameController.swift`
- Create: `TacXOTests/NearbyGameControllerTests.swift`

- [ ] **Step 1: Write failing host validation test**

```swift
import XCTest
@testable import TacXO

@MainActor
final class NearbyGameControllerTests: XCTestCase {
    func testHostRejectsMoveWhenNotPlayersTurn() {
        var settings = GameSettings.default
        settings.mode = .nearbyPvP
        let controller = NearbyGameController(settings: settings, isHost: true)
        controller.applyRemoteState(NearbyGameState(
            cells: [:],
            currentPlayer: .o,
            result: .ongoing,
            winningCells: []
        ))
        let accepted = controller.hostValidateMove(at: Cell(x: 0, y: 0), by: .x)
        XCTAssertFalse(accepted)
    }

    func testHostAcceptsValidMove() {
        var settings = GameSettings.default
        settings.mode = .nearbyPvP
        let controller = NearbyGameController(settings: settings, isHost: true)
        controller.applyRemoteState(NearbyGameState(
            cells: [:],
            currentPlayer: .x,
            result: .ongoing,
            winningCells: []
        ))
        let accepted = controller.hostValidateMove(at: Cell(x: 0, y: 0), by: .x)
        XCTAssertTrue(accepted)
    }
}
```

Expose `hostValidateMove` and `applyRemoteState` as `internal` for testing.

- [ ] **Step 2: Implement `NearbyGameController`**

Key properties:

```swift
@Observable
@MainActor
final class NearbyGameController {
    private(set) var phase: NearbySessionPhase = .idle
    private(set) var engine: GameEngine
    private(set) var localMark: Mark
    private(set) var discoveredHosts: [DiscoveredHost] = []
    private(set) var isPaused = false
    var settings: GameSettings

    var canAcceptInput: Bool {
        phase == .playing && !isPaused && engine.result == .ongoing && engine.currentPlayer == localMark
    }
}
```

Methods:

- `configure(service: NearbyGameService)` — inject service
- `beginSessionIfNeeded()` — called from Settings Done / PlayView onAppear when mode is nearby
- `startHosting()` / `startBrowsing()` / `cancelSession()` / `join(host:)`
- `tap(cell:)` — if host: validate + place + broadcast state; if joiner: send `.moveRequest`
- `handle(message:)` — apply invite/state/forfeit/rematch
- `forfeit()` — send `.forfeit`, end game
- `rematch()` — host sends `.rematchAccepted`, resets engine

- [ ] **Step 3: Run tests**

```bash
xcodebuild test -scheme TacXO -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:TacXOTests/NearbyGameControllerTests 2>&1 | tail -20
```

Expected: PASS.

- [ ] **Step 4: Commit**

```bash
git add TacXO/ViewModels/NearbyGameController.swift TacXOTests/NearbyGameControllerTests.swift
git commit -m "feat: add NearbyGameController with host-authoritative moves"
```

---

### Task 8: Settings UI

**Files:**
- Modify: `TacXO/Views/SettingsView.swift`

- [ ] **Step 1: Update mode picker to 3 segments**

Use segmented picker with all three `GameMode` cases. When `draft.mode == .nearbyPvP`:

1. Show role section with `NearbyRole` segmented picker.
2. Hide `win_length_section` and `board_size_section` when `draft.nearbyRole == .join`.

- [ ] **Step 2: On Done, trigger nearby session**

Pass a callback or environment object so Done calls:

```swift
if draft.mode == .nearbyPvP {
    nearbyController.settings = draft
    nearbyController.beginSessionIfNeeded()
} else {
    nearbyController.cancelSession()
}
controller.applySettings(draft) // local modes only; skip board reset for nearby pre-game
```

For nearby mode, do not reset local `GameController` board on Done — nearby controller owns pre-game UI.

- [ ] **Step 3: Build and commit**

```bash
xcodebuild -scheme TacXO -destination 'generic/platform=iOS' build 2>&1 | tail -5
git add TacXO/Views/SettingsView.swift
git commit -m "feat: settings UI for PvP nearby mode and host/join role"
```

---

### Task 9: Nearby lobby views

**Files:**
- Create: `TacXO/Views/NearbyWaitingView.swift`
- Create: `TacXO/Views/NearbyBrowseView.swift`
- Create: `TacXO/Views/NearbyPauseOverlay.swift`

- [ ] **Step 1: `NearbyWaitingView`**

Props: `settings`, `onCancel`. Paper background, pulsing icon, rules summary, Cancel button.

- [ ] **Step 2: `NearbyBrowseView`**

Props: `hosts: [DiscoveredHost]`, `onJoin: (DiscoveredHost) -> Void`. List with device name, `"\(boardSize.rawValue) · win \(winLength)"`, Join button. Empty state string `nearby_no_games`.

- [ ] **Step 3: `NearbyPauseOverlay`**

Props: `opponentName`, `onForfeit`. Semi-transparent overlay over board.

- [ ] **Step 4: Add strings to `Localizable.xcstrings`**

- `nearby_waiting` — "Waiting for opponent…"
- `nearby_no_games` — "No games nearby — ask a friend to host"
- `nearby_join` — "Join"
- `nearby_cancel` — "Cancel"
- `nearby_paused` — "Waiting for %@ to reconnect…"
- `nearby_forfeit` — "Forfeit"
- `nearby_your_turn` — "Your turn"
- `nearby_opponent_turn` — "Opponent's turn"

- [ ] **Step 5: Commit**

```bash
git add TacXO/Views/NearbyWaitingView.swift TacXO/Views/NearbyBrowseView.swift TacXO/Views/NearbyPauseOverlay.swift TacXO/Resources/Localizable.xcstrings
git commit -m "feat: nearby waiting, browse, and pause overlay views"
```

---

### Task 10: PlayView phase switching

**Files:**
- Modify: `TacXO/Views/PlayView.swift`

- [ ] **Step 1: Inject `NearbyGameController`**

```swift
struct PlayView: View {
    @Bindable var controller: GameController
    @Bindable var nearbyController: NearbyGameController
    // ...
}
```

- [ ] **Step 2: Switch main content**

```swift
@ViewBuilder
private var mainContent: some View {
    if controller.settings.mode == .nearbyPvP {
        switch nearbyController.phase {
        case .idle, .advertising:
            NearbyWaitingView(settings: nearbyController.settings, onCancel: { nearbyController.cancelSession() })
        case .browsing:
            NearbyBrowseView(hosts: nearbyController.discoveredHosts) { host in
                nearbyController.join(host: host)
            }
        case .connecting:
            ProgressView()
        case .playing, .paused:
            boardContent
        }
    } else {
        boardContent
    }
}
```

- [ ] **Step 3: Nearby board taps**

When `controller.settings.mode == .nearbyPvP` and `phase == .playing`:

```swift
BoardView(engine: nearbyController.engine, isInteractive: nearbyController.canAcceptInput) { cell in
    nearbyController.tap(cell: cell)
}
```

- [ ] **Step 4: Top bar adjustments**

- Hide hardness badge and new-game button when nearby pre-game (`advertising` / `browsing`).
- `statusLabel` uses nearby strings when in PvP mode.
- Show `NearbyPauseOverlay` when `nearbyController.isPaused`.

- [ ] **Step 5: Build and commit**

```bash
xcodebuild -scheme TacXO -destination 'generic/platform=iOS' build 2>&1 | tail -5
git add TacXO/Views/PlayView.swift
git commit -m "feat: PlayView switches between nearby lobby and board"
```

---

### Task 11: Wire app launch

**Files:**
- Modify: `TacXO/TacXOApp.swift`

- [ ] **Step 1: Initialize services**

```swift
@main
struct TacXOApp: App {
    @State private var controller = GameController()
    @State private var transferService: TransferService?
    @State private var nearbyController = NearbyGameController(settings: .load())

    var body: some Scene {
        WindowGroup {
            PlayView(controller: controller, nearbyController: nearbyController)
                .environment(\.locale, controller.settings.language.locale)
                .preferredColorScheme(.light)
                .task {
                    do {
                        let service = try TransferService()
                        try await service.start()
                        transferService = service
                        let gameService = NearbyGameService(transferService: service)
                        nearbyController.configure(service: gameService)
                        if controller.settings.mode == .nearbyPvP {
                            nearbyController.beginSessionIfNeeded()
                        }
                    } catch {
                        // log — PvP unavailable
                    }
                }
                .onAppear { _ = SoundManager.shared }
        }
    }
}
```

- [ ] **Step 2: Build and commit**

```bash
xcodebuild -scheme TacXO -destination 'generic/platform=iOS' build 2>&1 | tail -5
git add TacXO/TacXOApp.swift
git commit -m "feat: wire TransferService and NearbyGameController at launch"
```

---

### Task 12: Privacy doc and manual test checklist

**Files:**
- Modify: `PRIVACY.md`

- [ ] **Step 1: Add local network section**

Document that PvP Nearby uses local network/Bonjour only to discover peers and sync moves; no third-party servers.

- [ ] **Step 2: Run full unit tests**

```bash
xcodebuild test -scheme TacXO -destination 'platform=iOS Simulator,name=iPhone 16' 2>&1 | tail -30
```

Expected: all tests PASS.

- [ ] **Step 3: Manual test on two devices**

1. Device A: Settings → PvP Nearby → Host → 3×3 win 3 → Done → waiting screen.
2. Device B: Settings → PvP Nearby → Join → Done → see Device A → Join.
3. Play full game; verify moves sync.
4. Toggle airplane mode on one device → pause overlay → restore → state sync.
5. Forfeit → other player wins.
6. Switch to vs Uncle Sáu → MPC stops, normal game works.

- [ ] **Step 4: Commit**

```bash
git add PRIVACY.md
git commit -m "docs: update privacy for nearby PvP local network"
```

---

## Spec coverage check

| Spec requirement | Task |
|------------------|------|
| Third mode in Settings | Task 3, 8 |
| Host/Join role picker | Task 3, 8 |
| Join hides board settings | Task 8 |
| Host waiting on main | Task 9, 10 |
| Join browse on main | Task 5, 9, 10 |
| Host = X, joiner = O | Task 7 |
| Host-authoritative moves | Task 6, 7 |
| Pause on disconnect | Task 7, 9, 10 |
| No Uncle Sáu in PvP | Task 10 |
| communication-kit nearby | Task 1, 4, 6 |
| Physical device testing | Task 12 |

## Execution handoff

Plan complete and saved to `docs/superpowers/plans/2026-07-01-nearby-pvp.md`. Spec at `docs/superpowers/specs/2026-07-01-nearby-pvp-design.md`.

**Two execution options:**

1. **Subagent-Driven (recommended)** — fresh subagent per task, review between tasks
2. **Inline Execution** — implement tasks in this session with checkpoints

Which approach do you want?
