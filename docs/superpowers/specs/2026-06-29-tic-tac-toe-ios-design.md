# Tic-Tac-Toe iOS — Design Spec

**Date:** 2026-06-29  
**Status:** Approved  
**Codename:** TacXO (grumpy neighbor edition)

## Summary

A minimal iOS tic-tac-toe game with configurable rules, paper-classic visuals, and local-only play (2-player or vs a bitter AI neighbor). Pick up and play — no accounts, no onboarding, no online.

## Goals

- Super simple — open and play within 2 taps
- Configurable rules: win length (default 5) and board size (3×3, 5×5, 10×10, infinite)
- Paper / classic aesthetic
- Local only: 2-player pass-and-play or vs computer
- As small and simple as possible

## Platform Requirements

- **Minimum deployment target:** iOS **17.0**
- **Supported versions:** iOS 17 and all later releases (iOS 18, etc.)
- **Not supported:** iOS 16 and below
- **Devices (v1):** iPhone, portrait orientation

The app may use iOS 17+ APIs directly (`@Observable`, modern SwiftUI) without backward-compatibility shims for older OS versions.

## Stack

| Layer | Choice |
|-------|--------|
| UI | SwiftUI |
| Language | Swift 5.9+ |
| Minimum iOS | **17.0** |
| Persistence | UserDefaults |
| Audio | AVFoundation (short SFX clips) |
| Haptics | UIKit feedback generators |
| Dependencies | None |

**Architecture:** Thin layers, single target (Approach 2). ~12 Swift files, no Swift Package split.

```
Views → GameController → GameEngine
                      → AIPlayer (adaptive)
                      → NeighborPersonality (quotes + sounds)
```

## Screens

### Play (main)

- Paper-textured board area (scrollable in infinite mode)
- Turn indicator ("X's turn" / "O's turn")
- Settings gear (top)
- New Game button (bottom)
- Loss overlay (vs Neighbor only): toxic quote + auto-dismiss ~2s

### Settings

- **Win length:** picker/stepper, range 3–7, default **5**
- **Board size:** segmented control — `3×3` | `5×5` | `10×10` | `∞`
- **Mode:** segmented control — `2 Players` | `vs Neighbor`

Settings persist via UserDefaults. Returning to Play resets the board with new rules.

## Game Flow

```
Launch → Play (last saved rules)
  ├─ Tap cell → place mark → win/draw check
  ├─ vs Neighbor → AI responds after human move
  ├─ Win / Draw (fixed boards) → overlay → New Game
  └─ Loss (vs Neighbor) → difficulty down + quote + grumpy sound → New Game

Settings ⚙ → change rules → back to Play (board resets)
```

- **2 Players:** pass-and-play on one iPhone. No AI, no neighbor quotes.
- **vs Neighbor:** AI opponent with adaptive difficulty and personality.

## Game Engine

### Data model

Sparse board representation — only played cells stored:

```swift
typealias Cell = (x: Int, y: Int)
enum Mark { case x, case o }
var cells: [Cell: Mark]
```

Fixed-size boards use the same model with bounds checking. Infinite mode has no upper bound.

### Board modes

| Mode | Behavior |
|------|----------|
| 3×3 / 5×5 / 10×10 | Bounded grid; taps outside bounds ignored |
| Infinite | Starts as 7×7 visible window centered at (0,0); grows when moves occur near edges; pan to explore |

### Move lifecycle

1. Tap cell → validate empty + correct turn → place mark
2. Win check from **last move only** in 4 directions (horizontal, vertical, both diagonals)
3. If consecutive same marks ≥ win length → game over
4. Fixed boards: draw when no empty cells remain
5. Infinite mode: no draw detection in v1 — play continues until someone wins

### GameEngine API

| Method | Purpose |
|--------|---------|
| `place(at:)` | Validate, apply move, return result |
| `canPlay(at:)` | Empty cell + correct turn |
| `checkWin(from:)` | K-in-a-row from last move |
| `reset()` | Clear board, X goes first |

Pure Swift — no SwiftUI imports. Unit-testable.

### GameController

- Holds engine + current settings
- Manages turn switching (human / AI)
- Publishes state to SwiftUI (`@Observable`)
- Triggers neighbor personality on loss

## AI & Adaptive Difficulty

### Strategy by board type

| Board | Approach |
|-------|----------|
| 3×3, 5×5 | Minimax with alpha-beta pruning — effectively optimal |
| 10×10 | Bounded minimax (limited depth) + heuristic scoring |
| Infinite | Local search around recent moves + threat detection (block/take wins) |

### Difficulty levels (hidden, 0–5)

| Level | Behavior |
|-------|----------|
| 5 (default start) | Full search depth / best move |
| 4 | Slightly shallower search |
| 3 | ~20% chance of 2nd-best move |
| 2 | ~50% chance of 2nd-best move |
| 1 | Mostly random among top 3 moves |
| 0 | Noticeably weak |

- **User loses:** level decreases by 1 (floor 0) → show quote + grumpy sound
- **User wins:** level increases by 1 (ceiling 5)
- Persisted in UserDefaults across sessions

### AIPlayer interface

```swift
func bestMove(for engine: GameEngine, difficulty: Int) -> Cell
```

## Neighbor Personality

**Character:** bitter old neighbor — petty, mocking, unpleasant.

**On user loss (vs Neighbor only):**
1. Brief overlay with random quote (~1.5–2s), handwriting-style font
2. Grumpy sound effect (hmph / scoff / mutter)
3. Error-style haptic
4. Difficulty drops; ready for New Game

**Quote guidelines:**
- ~20 curated lines in cranky-old-man voice
- Rude and mocking; no slurs, hate speech, or explicit sexual content (App Store safe)
- Examples: "My dead dog plays better." / "You call that thinking?" / "Back in my day we had brains."

**On normal moves:**
- Pencil scratch / paper tap sound
- Light haptic on place

**2-player mode:** no neighbor quotes or AI sounds (optional paper SFX only).

## Visual Design

| Element | Treatment |
|---------|-----------|
| Background | Warm off-white/cream, subtle paper texture |
| Grid lines | Light gray, slightly imperfect |
| X marks | Red-ish or dark pencil, rough strokes |
| O marks | Blue-ish or dark pencil, rough strokes |
| Typography | System serif for UI; one handwriting font for quotes |
| Theme | Light only in v1 — no dark mode |

### Play layout

```
┌─────────────────────────┐
│  ⚙          X's turn    │
│   ┌─────────────────┐   │
│   │   board area    │   │  ← scrollable in infinite mode
│   └─────────────────┘   │
│      [ New Game ]       │
└─────────────────────────┘
```

## Audio & Haptics

| Asset | Trigger |
|-------|---------|
| `place.mp3` | Any move placed |
| `neighbor_loss_1..3.mp3` | Random on user loss vs Neighbor |
| Light impact haptic | Place mark |
| Error notification haptic | User loses |
| Success notification haptic | User wins (optional) |

All clips < 1 second. No background music. Preloaded at launch via SoundManager.

## File Structure

```
xo/
├── TacXOApp.swift
├── Models/
│   ├── Mark.swift
│   ├── Cell.swift
│   └── GameSettings.swift
├── Engine/
│   ├── GameEngine.swift
│   └── WinChecker.swift
├── AI/
│   ├── AIPlayer.swift
│   └── AdaptiveDifficulty.swift
├── Personality/
│   ├── NeighborQuotes.swift
│   └── SoundManager.swift
├── ViewModels/
│   └── GameController.swift
├── Views/
│   ├── PlayView.swift
│   ├── BoardView.swift
│   ├── CellView.swift
│   ├── SettingsView.swift
│   └── LossOverlayView.swift
└── Resources/
    ├── paper_texture.png
    ├── place.mp3
    └── neighbor_loss_1..3.mp3
```

## Testing

| Layer | Coverage |
|-------|----------|
| WinChecker | K-in-a-row (3/4/5), all directions, edge cells |
| GameEngine | Valid/invalid moves, turn switching, reset |
| AdaptiveDifficulty | Level up/down bounds (0–5) |
| AIPlayer | Blocks immediate win, takes winning move on 3×3 |

Unit tests for engine/AI only. No UI tests in v1.

## v1 Scope

### In

- iPhone portrait; **iOS 17.0+** (deployment target iOS 17.0)
- 2-player pass-and-play
- vs Neighbor with adaptive AI
- Board sizes: 3×3, 5×5, 10×10, infinite (pan)
- Win length 3–7 (default 5)
- Paper visual style
- Paper SFX + haptics + neighbor quotes/sounds on loss
- Settings persisted via UserDefaults

### Out (later)

- iPad layout
- Dark mode
- Online / Game Center
- Stats, leaderboards, undo
- Pinch-to-zoom
- Localization (English only v1)

## Success Criteria

1. Open app → play within 2 taps (no onboarding)
2. Change rules in Settings → instantly understood
3. 3×3 game completable in under a minute
4. Neighbor feels mean but fun after a loss
