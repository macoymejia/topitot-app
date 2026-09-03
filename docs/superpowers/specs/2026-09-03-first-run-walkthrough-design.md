# First-Run Walkthrough Design

**Goal:** Add a first-use caregiver guide that explains the main AAC screen and disappears permanently after dismissal.

## Summary

The app will show a short, dismissible coach-mark walkthrough on first launch after the launch splash clears. The guide stays on the AAC home screen, highlights the sentence strip, the grid, and the toolbar, and uses a simple card with short copy and large buttons.

## Behavior

- Show only on first use.
- Display three steps in order: Speak, board grid, Edit Board.
- Allow `Skip` on every step.
- End with `Get started` on the final step.
- Store completion in `shared_preferences`.
- Never show again after skip or completion.

## Visual Treatment

- Full-screen dark scrim.
- Highlight the active control when available.
- Bottom-aligned guidance card with large touch targets.
- Short, friendly caregiver-facing text.

## Fallbacks

- If a target cannot be measured, show the guidance card without a highlight.
- If the app layout changes, the guide should still be dismissible and functional.
