# Next Iteration Feature Notes

## Context

The AAC implementation is now split into focused app, AAC, model, service,
widget, and theme files. The current iteration also moved beyond a pure
architecture refactor by changing child-facing behavior.

## Current Product Direction

- Keep Topitot portrait-first on iOS/iPadOS and Android for predictable touch
  targets and reduced layout complexity.
- Use a 5 by 5 AAC board with Back and Home reserved as the first two grid
  cells.
- Keep the toolbar simple: expand/collapse, edit/use toggle, and reset.
- Use platform-default TTS with a slower speech rate and no child-facing voice
  selector.
- Keep board edits, custom photos, and folder structure stored locally.

## Recent Feature Changes

- Expanded the starter board with core words and category folders for Food,
  People, Actions, Feelings, and Places.
- Added a reset confirmation that restores `BoardLevel.starter()` and clears the
  current navigation path and edit state.
- Locked supported orientations to portrait in Flutter startup, Android, and
  iOS configuration.
- Removed selected voice persistence and toolbar voice selection from the AAC
  flow.
- Updated widget tests to use current root vocabulary and folder-level blank
  cells.

## Next Feature Candidates

- Caregiver settings screen for advanced actions such as voice choice, backup,
  restore, and reset.
- Starter-board versioning or migration so existing local boards can opt into
  new default vocabulary without silently replacing custom boards.
- Better reset options, such as reset current folder, reset all, or duplicate
  before reset.
- AAC vocabulary review with caregivers, teachers, or speech-language
  professionals before adding more default words.
- Focused unit tests for board JSON compatibility, starter board structure,
  photo validation, and reset persistence.

## Documentation Rules

- Update `README.md` whenever child-facing behavior changes.
- Keep historical implementation plans marked as superseded instead of silently
  rewriting their original constraints.
- New implementation plans should reference this document when changing toolbar,
  starter vocabulary, reset, TTS, or orientation behavior.
