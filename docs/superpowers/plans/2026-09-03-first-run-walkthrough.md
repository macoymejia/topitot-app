# First-Run Walkthrough Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a first-use caregiver walkthrough that explains Speak, the board grid, and Edit Board, then never shows again after dismissal.

**Architecture:** Keep the walkthrough inside `AacHomePage` so it can anchor to the real board controls without introducing a separate onboarding route. Persist completion with `shared_preferences`, render the guide as a full-screen overlay above the AAC screen, and keep the visual treatment lightweight so it stays child-friendly and easy to skip.

**Tech Stack:** Flutter, Dart, `shared_preferences`, widget tests

## Global Constraints

- The walkthrough is shown only on first use.
- The walkthrough is caregiver-focused, not a child tutorial.
- The walkthrough must be dismissible at any time.
- The walkthrough copy must stay short and simple.
- The AAC board remains the real home screen.
- Accessibility and large touch targets stay intact.

---

### Task 1: Add persistence for first-run walkthrough state

**Files:**
- Create: `lib/aac/services/walkthrough_storage_service.dart`

**Interfaces:**
- Consumes: `SharedPreferences`
- Produces: `hasSeenWalkthrough()` and `markWalkthroughSeen()`

- [ ] **Step 1: Create a failing test for first-run persistence**

```dart
testWidgets('walkthrough skip hides it and keeps it dismissed', (tester) async {
  mockTts();

  await tester.pumpWidget(const TopitotApp());
  await tester.pump(const Duration(seconds: 3));
  await tester.pump();

  await tester.tap(find.text('Skip'));
  await tester.pumpAndSettle();

  expect(find.byKey(const ValueKey<String>('walkthrough-overlay')), findsNothing);
});
```

- [ ] **Step 2: Run the test and confirm it fails before the service exists**

Run: `flutter test test/widget_test.dart --name "walkthrough skip hides it and keeps it dismissed" -v`

Expected: fail because the walkthrough storage and overlay are not implemented yet.

- [ ] **Step 3: Implement `WalkthroughStorageService`**

```dart
class WalkthroughStorageService {
  static const String walkthroughSeenKey = 'walkthrough_seen';

  Future<bool> hasSeenWalkthrough() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(walkthroughSeenKey) ?? false;
  }

  Future<void> markWalkthroughSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(walkthroughSeenKey, true);
  }
}
```

- [ ] **Step 4: Run the test again and confirm the persistence helper is wired in**

Run: `flutter test test/widget_test.dart --name "walkthrough skip hides it and keeps it dismissed" -v`

Expected: still failing until the overlay and page wiring are added.

### Task 2: Add the coach-mark overlay and anchor it to the board screen

**Files:**
- Create: `lib/aac/widgets/walkthrough_overlay.dart`
- Modify: `lib/aac/aac_home_page.dart`

**Interfaces:**
- Consumes: `Rect? targetRect`, step title/body text, primary button label, and skip/advance callbacks
- Produces: a full-screen overlay with a dark scrim and highlighted target area

- [ ] **Step 1: Add a failing widget test for the first-use overlay**

```dart
testWidgets('first-use walkthrough appears after the launch splash', (tester) async {
  mockTts();

  await tester.pumpWidget(const TopitotApp());
  await tester.pump(const Duration(seconds: 3));
  await tester.pump();

  expect(find.byKey(const ValueKey<String>('walkthrough-overlay')), findsOneWidget);
  expect(find.text('Welcome'), findsOneWidget);
  expect(find.text('Tap Speak to hear the words in your sentence.'), findsOneWidget);
});
```

- [ ] **Step 2: Run the test and verify it fails before implementation**

Run: `flutter test test/widget_test.dart --name "first-use walkthrough appears after the launch splash" -v`

Expected: fail because the overlay widget does not exist yet.

- [ ] **Step 3: Wire the walkthrough into `AacHomePage`**

Use `GlobalKey`s for the sentence strip, grid, and toolbar, measure the active target after layout, and render the overlay above the board only while the walkthrough is active.

- [ ] **Step 4: Add the overlay widget**

```dart
class WalkthroughOverlay extends StatelessWidget {
  const WalkthroughOverlay({
    super.key,
    required this.targetRect,
    required this.title,
    required this.body,
    required this.primaryLabel,
    required this.onPrimary,
    required this.onSkip,
  });
```

- [ ] **Step 5: Run the overlay test again and confirm it passes**

Run: `flutter test test/widget_test.dart --name "first-use walkthrough appears after the launch splash" -v`

Expected: pass.

### Task 3: Cover repeat suppression and validate the app

**Files:**
- Modify: `test/widget_test.dart`

**Interfaces:**
- Consumes: the persisted walkthrough flag and the overlay controls
- Produces: repeat suppression after skip or completion

- [ ] **Step 1: Add a failing test for walkthrough completion**

```dart
testWidgets('walkthrough completion hides it and keeps it dismissed', (tester) async {
  mockTts();

  await tester.pumpWidget(const TopitotApp());
  await tester.pump(const Duration(seconds: 3));
  await tester.pump();

  await tester.tap(find.text('Next'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Next'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Get started'));
  await tester.pumpAndSettle();

  expect(find.byKey(const ValueKey<String>('walkthrough-overlay')), findsNothing);
});
```

- [ ] **Step 2: Run the completion test and confirm it fails before the wiring exists**

Run: `flutter test test/widget_test.dart --name "walkthrough completion hides it and keeps it dismissed" -v`

Expected: fail until the walkthrough state machine exists.

- [ ] **Step 3: Run the full Flutter test suite**

Run: `flutter test`

Expected: all tests pass.

- [ ] **Step 4: Run static analysis**

Run: `flutter analyze`

Expected: no issues found.
