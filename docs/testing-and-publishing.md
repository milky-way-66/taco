# TacXO — Local Testing, TestFlight, and App Store Publishing

This guide covers how to run and test **TacXO** on your Mac, distribute builds via **TestFlight**, and submit to the **App Store**.

| Item | Value |
|------|-------|
| Bundle ID | `com.xo.game` |
| Minimum iOS | 17.0 |
| Xcode scheme | `TacXO` |
| Project config | `project.yml` (regenerate with `xcodegen` after edits) |

---

## Prerequisites

1. **Mac** with [Xcode](https://developer.apple.com/xcode/) installed (from the Mac App Store).
2. **Apple Developer Program** membership ($99/year) — you already have this.
3. **Apple ID** signed into Xcode: **Xcode → Settings → Accounts**.
4. Optional but recommended: [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`) if you edit `project.yml`.

---

## 1. Local testing

### Open the project

```bash
cd /Users/khang/work/side-project/xo
open TacXO.xcodeproj
```

If you changed `project.yml`, regenerate the Xcode project first:

```bash
xcodegen generate
open TacXO.xcodeproj
```

### Run unit tests

**In Xcode:** select the **TacXO** scheme → **Product → Test** (⌘U).

**From the terminal:**

```bash
xcodebuild -scheme TacXO \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  test
```

Run a single test class:

```bash
xcodebuild -scheme TacXO \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  test -only-testing:TacXOTests/GameEngineTests
```

### Run in the iOS Simulator

1. In Xcode, choose a simulator (e.g. **iPhone 16**) from the device menu next to the scheme.
2. Press **Run** (⌘R).

The app should open directly on the board — no onboarding.

**Smoke checklist:**

- [ ] Place marks on a 3×3 board; win is detected.
- [ ] **Settings** → switch to vs Neighbor; AI responds.
- [ ] Lose on purpose → neighbor quote overlay + sound/haptic.
- [ ] Change language in Settings; UI updates.
- [ ] Kill and relaunch app; settings persist.

### Run on a physical iPhone/iPad

1. Connect the device via USB (or enable wireless debugging in **Window → Devices and Simulators**).
2. On the device: **Settings → Privacy & Security → Developer Mode** → enable (restart if prompted).
3. In Xcode, select your device in the scheme menu.
4. **Signing & Capabilities** tab on the **TacXO** target:
   - Check **Automatically manage signing**.
   - Choose your **Team** (your Apple Developer account).
5. Press **Run** (⌘R). Trust the developer certificate on the device if iOS asks.

This is the best way to test real haptics, audio levels, and performance.

### Build from the command line (no Xcode UI)

```bash
xcodebuild -scheme TacXO \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  build
```

---

## 2. TestFlight

TestFlight lets you install release builds on your own devices and share with beta testers before App Store release.

### One-time setup

#### A. Create the app in App Store Connect

1. Go to [App Store Connect](https://appstoreconnect.apple.com).
2. **Apps → + → New App**.
3. Fill in:
   - **Platform:** iOS
   - **Name:** TacXO
   - **Primary language**
   - **Bundle ID:** `com.xo.game` (must match `project.yml`)
   - **SKU:** any unique string (e.g. `tacxo-game-001`)
4. Create the app record. You do **not** need to submit for review yet.

#### B. Configure signing in Xcode

1. Open `TacXO.xcodeproj` → select the **TacXO** target → **Signing & Capabilities**.
2. Enable **Automatically manage signing**.
3. Select your **Team**.
4. Confirm **Bundle Identifier** is `com.xo.game`.
5. Repeat for **TacXOTests** if Xcode warns about signing (usually automatic).

Xcode will create a Distribution certificate and App Store provisioning profile when you archive.

#### C. App icon (required before upload)

App Store Connect rejects builds without a 1024×1024 app icon.

1. Add a 1024×1024 PNG to `TacXO/Resources/Assets.xcassets/AppIcon.appiconset/`.
2. Update `Contents.json` in that folder, or drag the image into the App Icon slot in Xcode’s asset catalog.

### Upload a build

#### Step 1: Set version and build number

In Xcode → **TacXO** target → **General**:

| Field | Example | Notes |
|-------|---------|-------|
| **Version** | `1.0.0` | User-visible; bump for each App Store release |
| **Build** | `1` | Must increase for every upload to App Store Connect |

Or edit `project.yml` and run `xcodegen generate`:

```yaml
settings:
  base:
    MARKETING_VERSION: "1.0.0"
    CURRENT_PROJECT_VERSION: "1"
```

#### Step 2: Archive

1. Select **Any iOS Device (arm64)** as the run destination (not a simulator).
2. **Product → Archive**.
3. When the Organizer opens, select the archive → **Distribute App**.
4. Choose **App Store Connect** → **Upload**.
5. Follow the prompts (include symbols, automatic signing).
6. Wait for “Upload Successful”.

#### Step 3: Wait for processing

In App Store Connect → your app → **TestFlight** tab:

- The build appears under **iOS Builds** with status **Processing** (usually 5–30 minutes).
- When ready, status becomes **Ready to Submit** / available for testing.

If processing fails, check email from Apple or **Activity** in App Store Connect for errors (missing icon, invalid entitlements, etc.).

### Install via TestFlight

#### Internal testing (fastest)

- Up to 100 members of your App Store Connect team.
- No Beta App Review required.
- Build is available shortly after processing.

1. App Store Connect → **TestFlight → Internal Testing**.
2. Create a group (e.g. “Team”) and add the build.
3. On your iPhone, install [TestFlight](https://apps.apple.com/app/testflight/id899247664) from the App Store.
4. Accept the invite email or open the TestFlight link.
5. Install **TacXO** and test.

#### External testing (wider audience)

- Up to 10,000 external testers via public link or email invite.
- First build for a version requires **Beta App Review** (usually 24–48 hours).
- Fill in **Test Information** (what to test, contact email) before submitting for beta review.

### TestFlight tips

- Each new upload needs a **higher build number** (`1` → `2` → `3` …).
- TestFlight builds expire after **90 days**.
- Use **Release** configuration for archives (Xcode Archive does this by default).
- Test on the oldest device/iOS version you support (iOS 17).

---

## 3. Publish to the App Store

### Before you submit

Complete these in App Store Connect under your app:

| Requirement | Where |
|-------------|-------|
| App icon (1024×1024) | Xcode asset catalog |
| Screenshots (6.7", 6.5", 5.5" etc.) | App Store → Screenshots |
| Description, keywords, support URL | App Information |
| Privacy Policy URL | Required for all apps |
| Age rating questionnaire | App Privacy |
| App Privacy details (data collection) | App Privacy — TacXO likely collects **no data** if you don’t use analytics |
| Copyright, category | App Information |

**TacXO-specific checks:**

- Verify `paper_texture.jpg` license in `TacXO/Resources/ATTRIBUTIONS.md` is acceptable for commercial distribution.
- Confirm neighbor audio assets are yours or properly licensed.

### Choose a build

1. App Store Connect → your app → **App Store** tab.
2. Click **+ Version** (e.g. `1.0.0`).
3. Under **Build**, select the TestFlight build you validated.
4. Fill in **What’s New in This Version**.

### Submit for review

1. Complete all required fields (red warnings must be resolved).
2. **Add for Review** → **Submit to App Review**.
3. Answer export compliance (TacXO has no encryption beyond standard HTTPS — typically “No” for custom encryption).
4. Wait for review (often 24–48 hours; can be longer).

### After approval

- **Manual release:** you click **Release** when ready.
- **Automatic release:** goes live shortly after approval.
- Monitor **Ratings and Reviews** and crash reports in App Store Connect.

### Updating later

1. Bump **Version** (e.g. `1.0.0` → `1.1.0`) for user-visible changes.
2. Bump **Build** for every upload.
3. Archive → Upload → select new build in App Store Connect → submit.

---

## Quick reference

| Goal | Command / action |
|------|------------------|
| Regenerate Xcode project | `xcodegen generate` |
| Run tests | `xcodebuild -scheme TacXO -destination 'platform=iOS Simulator,name=iPhone 16' test` |
| Run on simulator | Xcode → ⌘R |
| Run on device | Connect device, set signing team, ⌘R |
| Upload to TestFlight | **Product → Archive** → Distribute → App Store Connect |
| Install beta | TestFlight app on iPhone |
| Go live | App Store Connect → Submit for Review → Release |

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| “No signing certificate” | Xcode → Settings → Accounts → Manage Certificates → **+** Apple Distribution |
| “Bundle ID not found” | Create app in App Store Connect with `com.xo.game`, or register ID at [developer.apple.com](https://developer.apple.com/account/resources/identifiers/list) |
| Archive button disabled | Select **Any iOS Device**, not a simulator |
| Build stuck “Processing” | Wait up to an hour; check email for rejection reason |
| Tests fail on CI/local | Ensure simulator name exists: `xcrun simctl list devices available` |
| Changed `project.yml` but Xcode looks wrong | Run `xcodegen generate` and reopen the project |

---

## Useful links

- [App Store Connect](https://appstoreconnect.apple.com)
- [Apple Developer Account](https://developer.apple.com/account)
- [TestFlight overview](https://developer.apple.com/testflight/)
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
