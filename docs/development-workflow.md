# TacXO Development Workflow

TacXO follows **Documentation-Driven Development (DDD)** and **Test-Driven Development (TDD)**.

Every change follows this order:

```
Docs → Tests → Code → Update docs
```

No production code without a written spec and a failing test first.

---

## 1. Documentation first (DDD)

Before writing or changing behavior, write or update a spec.

### Where specs live

| Type | Path | When to use |
|------|------|-------------|
| Feature / product spec | `docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md` | New features, rule changes, UX changes |
| Implementation plan | `docs/superpowers/plans/YYYY-MM-DD-<topic>.md` | Multi-step work after spec is approved |
| Small change spec | `docs/features/YYYY-MM-DD-<topic>.md` | Single focused change (e.g. add a board size) |
| Ops / release | `docs/testing-and-publishing.md` | Build, TestFlight, App Store |

Use the template at [`docs/templates/feature-spec.md`](templates/feature-spec.md).

### What a spec must include

1. **Summary** — one paragraph: what and why
2. **Acceptance criteria** — numbered, testable statements
3. **Behavior details** — edge cases, defaults, persistence, UI
4. **Out of scope** — what this change does *not* cover
5. **Status** — `Draft` → `Approved` → `Implemented` (or `Superseded`)

### Spec rules

- **No code until the spec exists** (except throwaway spikes — delete spikes before the real cycle).
- **Get approval** on non-trivial specs before writing tests.
- **Update the spec** when requirements change during implementation.
- **Mark status** when implementation is done.

---

## 2. Tests second (TDD)

Tests are derived directly from the spec’s acceptance criteria.

### Where tests live

| Layer | Path |
|-------|------|
| Unit / engine tests | `TacXOTests/` |
| Test target | `TacXOTests` (Xcode scheme `TacXO`) |

Mirror production layout where it helps: `GameEngine` → `GameEngineTests.swift`, `WinChecker` → `WinCheckerTests.swift`.

### TDD cycle (Red → Green → Refactor)

1. **Red** — write a failing test that maps to one acceptance criterion
2. **Verify red** — run tests; confirm the failure is for the right reason
3. **Green** — write the smallest production change to pass
4. **Verify green** — run the full test suite
5. **Refactor** — clean up; keep tests green
6. Repeat until all acceptance criteria have tests and pass

```bash
xcodebuild -scheme TacXO \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  test
```

Run a single test class while iterating:

```bash
xcodebuild -scheme TacXO \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  test -only-testing:TacXOTests/GameEngineTests
```

### Test rules

- **No production code without a failing test first.**
- If code was written before tests, remove it and implement again from tests.
- Each acceptance criterion should map to at least one test (name or comment reference helps).
- Bug fixes: add a test that reproduces the bug, then fix.

---

## 3. Code third

Implement only what the tests require.

### Production code layout

```
TacXO/
  Models/       # GameSettings, Cell, Mark
  Engine/       # GameEngine, WinChecker
  AI/           # AIPlayer, AdaptiveDifficulty
  Views/        # SwiftUI screens
  ViewModels/   # GameController
  Resources/    # Assets, localization
```

### Code rules

- Match existing naming, patterns, and file placement.
- Keep changes minimal and focused on the spec.
- Do not add behavior that is not in the spec and tests.

---

## 4. Maintain docs (always)

Documentation is not a one-time step. Keep it in sync with the product.

### When to update docs

| Event | Action |
|-------|--------|
| Feature shipped | Set spec status to `Implemented`; update `README.md` if user-visible |
| Behavior changed | Update spec + acceptance criteria before or with the code change |
| Feature removed | Mark spec `Superseded`; note replacement or removal |
| New board size / setting | Update spec, `README.md`, and `PRIVACY.md` if settings change |
| Release | Follow `docs/testing-and-publishing.md` |

### Doc maintenance checklist (every change)

```
[ ] Spec exists or is updated
[ ] Acceptance criteria match tests
[ ] Spec status is current
[ ] README / PRIVACY updated if user-facing
[ ] All tests pass
```

---

## Example: adding a board size

### 1. Doc — `docs/features/2026-07-01-board-size-14x16.md`

- Acceptance: 14×14 and 16×16 appear in Settings
- Acceptance: games play correctly on both sizes
- Acceptance: large boards scroll on small screens
- Acceptance: AI remains responsive

### 2. Test — `GameEngineTests.swift`

```swift
func testFourteenByFourteenBoardBounds() {
    let engine = GameEngine(settings: GameSettings(winLength: 5, boardSize: .fourteen, mode: .twoPlayer))
    XCTAssertTrue(engine.canPlay(at: Cell(x: 13, y: 13)))
    XCTAssertFalse(engine.canPlay(at: Cell(x: 14, y: 0)))
}
```

Run tests → **fail** (enum case missing).

### 3. Code — `GameSettings.swift`

Add `fourteen` and `sixteen` cases; run tests → **pass**.

### 4. Maintain

- Set feature spec status to `Implemented`
- Update `README.md` board size list

---

## Quick reference

| Step | Output |
|------|--------|
| 1. Doc | Spec with acceptance criteria |
| 2. Test | Failing test(s) in `TacXOTests/` |
| 3. Code | Minimal implementation in `TacXO/` |
| 4. Maintain | Spec status, README, full test run |

**Order is mandatory:** Docs → Tests → Code → Update docs.
