# Agent instructions (TacXO)

This project uses **DDD + TDD**: documentation first, then tests, then code.

## Read first

- [`docs/development-workflow.md`](docs/development-workflow.md) — full workflow
- [`docs/templates/feature-spec.md`](docs/templates/feature-spec.md) — spec template
- [`.cursor/rules/ddd-tdd-workflow.mdc`](.cursor/rules/ddd-tdd-workflow.mdc) — Cursor rule (always on)

## Order of work

```
1. Spec (acceptance criteria)  →  docs/superpowers/specs/ or docs/features/
2. Failing tests               →  TacXOTests/
3. Implementation                →  TacXO/
4. Doc maintenance             →  status, README, PRIVACY if needed
```

## Do not

- Skip the spec for features or behavior changes
- Write production code before a failing test exists
- Leave docs stale after shipping behavior changes

## Test command

```bash
xcodebuild -scheme TacXO -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test
```

## Project layout

- `TacXO/` — app source (Models, Engine, AI, Views, ViewModels)
- `TacXOTests/` — XCTest unit tests
- `docs/` — specs, plans, workflow, release guides
