# Toolbar App Icon Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the toolbar's left placeholder mark with the app icon and change the adjacent label to a smaller bold `Speech Relay` that fits the same width as the current `Topitot` text.

**Architecture:** Keep the change local to the board toolbar identity widget. That widget already owns the icon mark and title text, so the cleanest change is to replace the placeholder icon container with an asset image and tune the text style inside the same component without touching the rest of the toolbar layout.

**Tech Stack:** Flutter, Dart, asset images, widget tests

## Global Constraints

- Replace the left toolbar mark with the app icon.
- Change the label from `Topitot` to `Speech Relay`.
- Keep the label on one line and shrink it to fit the same approximate width as the current text.
- Use bold text and keep it readable.
- Do not change unrelated toolbar behavior or AAC board logic.

---

### Task 1: Swap the toolbar mark for the app icon and update the label

**Files:**
- Modify: `lib/aac/widgets/board_toolbar.dart`

**Interfaces:**
- Consumes: `assets/images/speech-relay-by-topitot-logo-1000x1000.png`
- Produces: a toolbar identity row that shows the app icon and the `Speech Relay` label

- [ ] **Step 1: Update the toolbar identity widget**

Replace the `_AppIconMark` placeholder with an `Image.asset` using the app icon source, and change the text from `Topitot` to `Speech Relay`.

- [ ] **Step 2: Fit the label to the old width**

Keep the label on one line with a bold weight and a smaller font size than the current `Topitot` text so it fits the same space without wrapping.

- [ ] **Step 3: Verify the widget compiles**

Run: `flutter test`

Expected: existing widget tests still pass and the toolbar renders with the updated identity.

- [ ] **Step 4: Commit**

```bash
git add lib/aac/widgets/board_toolbar.dart
git commit -m "feat: update toolbar app icon"
```
