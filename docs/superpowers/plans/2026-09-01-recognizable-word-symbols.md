# Recognizable Word Symbols Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace abstract or black-looking default word-button symbols with more recognizable child-friendly emoji.

**Architecture:** The starter AAC board defines labels, spoken text, symbols, and colors in `BoardLevel.starter()`. This change updates only default symbol strings and adds a model-level regression test for those defaults.

**Tech Stack:** Flutter, Dart, `flutter_test`.

## Global Constraints

- Use Flutter Material 3.
- Prioritize accessibility over aesthetics.
- All UI elements must use large touch targets and high contrast.
- Avoid hardcoded colors outside `lib/theme/app_colors.dart`; this task changes symbols only.
- Do not modify unrelated dirty worktree changes.

---

### Task 1: Default Symbol Cleanup

**Files:**
- Modify: `test/widget_test.dart`
- Modify: `lib/aac/models/board_models.dart`

**Interfaces:**
- Consumes: `BoardLevel.starter()` returning a `BoardLevel` with `List<AacCell> cells`.
- Produces: starter-board cells whose `symbol` values avoid the abstract defaults `➕`, `👉`, `❓`, `🔓`, and `🔒`.

- [ ] **Step 1: Write the failing test**

Add assertions to the existing starter-board defaults test:

```dart
expect(board.cells[2].symbol, '🔁');
expect(board.cells[3].symbol, '👋');
expect(board.cells[18].symbol, '👤');
expect(actionCells.firstWhere((cell) => cell.label == 'to open').symbol, '🚪');
expect(actionCells.firstWhere((cell) => cell.label == 'to close').symbol, '📕');
```

- [ ] **Step 2: Run the focused test to verify it fails**

Run: `flutter test test/widget_test.dart --plain-name "starter board uses action phrase labels for root and Actions cells"`

Expected: FAIL because the current symbols are `➕`, `👉`, `❓`, `🔓`, and `🔒`.

- [ ] **Step 3: Write minimal implementation**

In `lib/aac/models/board_models.dart`, change only these starter defaults:

```dart
AacCell.speak('more', 'more', '🔁', AppColors.lavender),
AacCell.speak('you', 'you', '👋', AppColors.yellowSoft),
AacCell.speak('to open', 'to open', '🚪', AppColors.greenSoft),
AacCell.speak('to close', 'to close', '📕', AppColors.greenSoft),
AacCell.speak('who', 'who', '👤', AppColors.lavender),
```

- [ ] **Step 4: Run focused test to verify it passes**

Run: `flutter test test/widget_test.dart --plain-name "starter board uses action phrase labels for root and Actions cells"`

Expected: PASS.

- [ ] **Step 5: Format and verify**

Run: `dart format lib/aac/models/board_models.dart test/widget_test.dart`

Run: `flutter analyze`

Run: `flutter test`

Expected: analyzer reports no issues and all tests pass.
