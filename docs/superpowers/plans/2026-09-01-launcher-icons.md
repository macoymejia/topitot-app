# Launcher Icons Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the default Flutter launcher icons on Android and iOS with icons generated from `assets/images/speech-relay-by-topitot-logo-1000x1000.png`.

**Architecture:** Keep the icon source centralized in one square PNG and let `flutter_launcher_icons` generate the platform-specific launcher assets. That minimizes manual file editing, keeps Android and iOS in sync, and preserves the existing launcher references (`@mipmap/ic_launcher` and `AppIcon.appiconset`) so the app code does not need to change.

**Tech Stack:** Flutter, Dart, `flutter_launcher_icons`, Android mipmap resources, iOS asset catalogs

## Global Constraints

- Android launcher icon no longer shows the Flutter logo.
- iOS launcher icon no longer shows the Flutter logo.
- Both platforms use icons derived from `assets/images/speech-relay-by-topitot-logo-1000x1000.png`.
- The app code and AAC behavior remain unchanged.

---

### Task 1: Configure launcher icon generation

**Files:**
- Modify: `pubspec.yaml`

**Interfaces:**
- Consumes: `assets/images/speech-relay-by-topitot-logo-1000x1000.png`
- Produces: a `flutter_launcher_icons` config that can generate Android and iOS launcher assets

- [ ] **Step 1: Add a dependency test case by running pub get after the config is added**

The change should make `flutter pub get` accept the new dev dependency and config.

- [ ] **Step 2: Add `flutter_launcher_icons` to `dev_dependencies`**

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
  flutter_launcher_icons: ^0.14.4
```

- [ ] **Step 3: Add the icon generator config**

```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: assets/images/speech-relay-by-topitot-logo-1000x1000.png
```

- [ ] **Step 4: Run dependency resolution**

Run: `flutter pub get`

Expected: dependencies resolve successfully and the new launcher icon config is recognized.

- [ ] **Step 5: Commit**

```bash
git add pubspec.yaml
git commit -m "feat: configure launcher icon generation"
```

### Task 2: Generate Android and iOS launcher assets

**Files:**
- Modify: `android/app/src/main/res/mipmap-*/ic_launcher.png`
- Modify: `android/app/src/main/res/mipmap-*/ic_launcher_round.png` if generated
- Modify: `android/app/src/main/res/mipmap-anydpi-v26/*` if generated
- Modify: `ios/Runner/Assets.xcassets/AppIcon.appiconset/*`

**Interfaces:**
- Consumes: the `flutter_launcher_icons` config from Task 1
- Produces: platform launcher assets derived from the 1000x1000 source PNG

- [ ] **Step 1: Generate the icons**

Run: `dart run flutter_launcher_icons`

Expected: Android and iOS icon files are regenerated from the source PNG.

- [ ] **Step 2: Inspect the generated files**

Confirm the Android mipmap files and iOS `AppIcon.appiconset` entries were updated and still match the launcher references used by the app.

- [ ] **Step 3: Commit**

```bash
git add android/app/src/main/res ios/Runner/Assets.xcassets
git commit -m "feat: generate launcher icons from topitot logo"
```

### Task 3: Verify the new icons on device and in build outputs

**Files:**
- Verify: `flutter analyze`, `flutter test`, Android reinstall on a phone

**Interfaces:**
- Consumes: the generated launcher assets from Task 2
- Produces: verified launcher icon replacement on Android and iOS build artifacts

- [ ] **Step 1: Run static checks**

Run: `flutter analyze`

Expected: no issues found.

- [ ] **Step 2: Run the widget suite**

Run: `flutter test`

Expected: all tests pass.

- [ ] **Step 3: Build the Android app bundle or reinstall the app on the phone**

Run: `flutter build appbundle`

Expected: the build completes and uses the regenerated launcher assets.

- [ ] **Step 4: Verify the launcher icon on the Android phone**

Uninstall the existing app from the phone, reinstall the new build, and confirm the launcher no longer shows the Flutter logo.

- [ ] **Step 5: Commit**

```bash
git add docs/superpowers/plans/2026-09-01-launcher-icons.md
git commit -m "test: verify launcher icons"
```
