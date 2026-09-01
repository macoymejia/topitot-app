# Transparent Launch Splash Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Show a transparent launch splash with the provided Speech Relay artwork on app start, then hide it automatically after 3 seconds.

**Architecture:** Keep the AAC home screen as the real destination and layer a temporary Flutter splash overlay above it at app startup. The overlay will be a small reusable widget with its own visibility state and timer cleanup, so the launch behavior stays isolated from AAC board logic.

**Tech Stack:** Flutter, Dart, widget tests, `pubspec.yaml` asset registration

## Global Constraints

- The splash is only shown on app launch.
- The splash is transparent rather than an opaque full-screen page.
- The Speech Relay artwork is centered and visible during the splash.
- The splash hides automatically after 3 seconds.
- The AAC home screen is still the destination after the splash disappears.
- No new onboarding flow.
- No persistent launch preference.
- No changes to AAC board behavior.
- No changes to the native Android or iOS splash screens beyond keeping them functional.

---

### Task 1: Register the launch artwork asset

**Files:**
- Create: `assets/images/launch/speech_relay_launch.png`
- Modify: `pubspec.yaml`

**Interfaces:**
- Consumes: the provided Speech Relay artwork image
- Produces: a Flutter asset path that `AssetImage` can load from the launch overlay

- [ ] **Step 1: Add the provided PNG to the asset path**

Save the supplied image as `assets/images/launch/speech_relay_launch.png`.

- [ ] **Step 2: Register the asset in `pubspec.yaml`**

```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/images/launch/speech_relay_launch.png
```

- [ ] **Step 3: Verify Flutter can see the asset**

Run: `flutter pub get`

Expected: dependency resolution succeeds and Flutter accepts the new asset entry.

- [ ] **Step 4: Commit**

```bash
git add pubspec.yaml assets/images/launch/speech_relay_launch.png
git commit -m "feat: add launch splash asset"
```

### Task 2: Add the transparent launch overlay widget

**Files:**
- Modify: `lib/app/topitot_app.dart`
- Create: `lib/app/widgets/launch_splash_overlay.dart`

**Interfaces:**
- Consumes: `AacHomePage` and `TopitotTheme.light`
- Produces: a `LaunchSplashOverlay` widget with a `visible` state controlled by `TopitotApp`

- [ ] **Step 1: Write a widget test that expects the splash to disappear after 3 seconds**

Add a new widget test in `test/widget_test.dart`:

```dart
testWidgets('launch splash disappears after 3 seconds', (tester) async {
  mockTts();

  await tester.pumpWidget(const TopitotApp());
  expect(find.byType(LaunchSplashOverlay), findsOneWidget);

  await tester.pump(const Duration(seconds: 3));
  await tester.pump();

  expect(find.byType(LaunchSplashOverlay), findsNothing);
  expect(find.byType(AacHomePage), findsOneWidget);
});
```

- [ ] **Step 2: Run the new test and confirm it fails before implementation**

Run: `flutter test test/widget_test.dart --name "launch splash disappears after 3 seconds" -v`

Expected: fail because `LaunchSplashOverlay` does not exist yet.

- [ ] **Step 3: Implement the overlay widget**

Create a widget that renders a transparent `SizedBox.expand`/`ColoredBox` background, centers `Image.asset('assets/images/launch/speech_relay_launch.png')`, and returns `SizedBox.shrink()` when `visible` is false.

```dart
class LaunchSplashOverlay extends StatelessWidget {
  const LaunchSplashOverlay({super.key, required this.visible});

  final bool visible;

  @override
  Widget build(BuildContext context) {
    if (!visible) {
      return const SizedBox.shrink();
    }

    return const ColoredBox(
      color: Colors.transparent,
      child: Center(
        child: Image(
          image: AssetImage('assets/images/launch/speech_relay_launch.png'),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Update `TopitotApp` to show the overlay only once at startup**

Change `TopitotApp` from a stateless shell into a small stateful shell that:

```dart
Stack(
  children: <Widget>[
    const AacHomePage(),
    if (_showLaunchSplash) const Positioned.fill(child: LaunchSplashOverlay(visible: true)),
  ],
)
```

The widget should start with `_showLaunchSplash = true`, schedule a 3-second `Timer`, and call `setState` to remove the overlay. Cancel the timer in `dispose()`.

- [ ] **Step 5: Run the widget test again and confirm it passes**

Run: `flutter test test/widget_test.dart --name "launch splash disappears after 3 seconds" -v`

Expected: pass.

- [ ] **Step 6: Commit**

```bash
git add lib/app/topitot_app.dart lib/app/widgets/launch_splash_overlay.dart test/widget_test.dart
git commit -m "feat: add transparent launch splash"
```

### Task 3: Verify launch behavior and release safety

**Files:**
- Modify: `test/widget_test.dart`
- Verify: `flutter analyze`, `flutter test`, `flutter build appbundle`

**Interfaces:**
- Consumes: the implemented overlay and asset registration from Tasks 1 and 2
- Produces: confidence that startup still works and the release build still packages the new asset

- [ ] **Step 1: Add a smoke test that the app still opens the AAC screen underneath the overlay**

```dart
testWidgets('launch splash keeps the AAC home screen underneath', (tester) async {
  mockTts();

  await tester.pumpWidget(const TopitotApp());
  await tester.pump();

  expect(find.byType(AacHomePage), findsOneWidget);
  expect(find.text('Choose words'), findsOneWidget);
});
```

- [ ] **Step 2: Run the full widget suite**

Run: `flutter test`

Expected: all tests pass.

- [ ] **Step 3: Run static analysis**

Run: `flutter analyze`

Expected: no issues found.

- [ ] **Step 4: Build the signed Android bundle**

Run: `flutter build appbundle`

Expected: release bundle builds successfully with the new asset included.

- [ ] **Step 5: Commit**

```bash
git add test/widget_test.dart
git commit -m "test: cover launch splash startup behavior"
```
