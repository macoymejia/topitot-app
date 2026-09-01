# Architecture Refactor Design

Status: Superseded by `docs/superpowers/specs/2026-08-31-next-iteration-features.md`.

This document describes the original behavior-preserving architecture split.
Later work intentionally changed product behavior by simplifying TTS, expanding
starter vocabulary, adding board reset, and locking the app to portrait.

## Context

Topitot is a Flutter Material 3 AAC app for children who are non-verbal or speech-delayed. The current app already has core AAC behavior: a 5 by 5 board, folder navigation, sentence strip speech, editable cells, custom photos, TTS voice selection, and local persistence.

Most of the implementation is currently concentrated in `lib/main.dart`, which contains app startup, screen state, TTS handling, board persistence, photo storage, AAC widgets, editor widgets, and local data models. This makes future feature work riskier because unrelated responsibilities must be edited in one large file.

## Goal

Refactor the app into focused files while preserving behavior exactly. The first priority is safer future feature work, not changing the user experience.

The refactor should keep the current child-friendly AAC experience intact:

- Same 5 by 5 board layout.
- Same starter board content.
- Same sentence strip behavior.
- Same edit mode behavior.
- Same folder navigation and maximum depth.
- Same voice selection behavior.
- Same local persistence keys.
- Same photo selection, validation, and storage behavior.

## Non-Goals

- No redesign of the board or toolbar.
- No new profiles, board library, or settings screen.
- No state management package.
- No persistence migration.
- No change to saved preference keys or JSON field names.
- No broad cleanup unrelated to splitting responsibilities.

## Recommended Approach

Use a conservative structural split with narrow services. `AacHomePage` remains the orchestrating stateful screen, while reusable widgets, models, constants, and platform/local side effects move out of `main.dart`.

This is safer than a full feature-layer rewrite and more useful than only moving widgets because it isolates TTS, board storage, and photo storage for future features.

## File Structure

```text
lib/
  main.dart
  app/
    topitot_app.dart
  aac/
    aac_home_page.dart
    constants/
      aac_constants.dart
    models/
      aac_cell.dart
      board_level.dart
      tts_voice.dart
    services/
      board_storage_service.dart
      photo_storage_service.dart
      tts_service.dart
    widgets/
      aac_grid.dart
      aac_tile.dart
      board_toolbar.dart
      cell_editor_dialog.dart
      cell_visual.dart
      sentence_strip.dart
  theme/
    app_colors.dart
    app_radius.dart
    app_spacing.dart
    app_typography.dart
    topitot_theme.dart
```

## Components

### App Entry

`lib/main.dart` should only call `runApp(const TopitotApp())` and import `app/topitot_app.dart`.

`TopitotApp` moves to `lib/app/topitot_app.dart`. It keeps the same `MaterialApp` title, theme, debug banner setting, and home screen.

### AAC Screen

`AacHomePage` moves to `lib/aac/aac_home_page.dart`. It remains a `StatefulWidget` and keeps the main app state:

- Current root board.
- Current folder path.
- Sentence cells.
- Loading state.
- Edit mode.
- Toolbar expansion state.
- Available voices and selected voice.

The screen coordinates services and widgets but should no longer define model classes, low-level TTS parsing, photo file writing, or the reusable AAC UI widgets.

### Constants

`lib/aac/constants/aac_constants.dart` owns AAC constants:

- `boardRows`
- `boardColumns`
- `cellsPerPage`
- `maxFolderDepth`
- `maxCellPhotoBytes`

These names stay unchanged so existing tests and references remain simple.

### Models

`BoardLevel`, `AacCell`, `CellKind`, and `CellVisualType` move into model files.

`BoardLevel.starter()` should remain the source of starter board content. JSON serialization should stay compatible with current saved data:

- `title`
- `cells`
- `label`
- `spokenText`
- `symbol`
- `visualType`
- `photoPath`
- `color`
- `kind`
- `children`

`TtsVoice` moves to `lib/aac/models/tts_voice.dart` and preserves label, storage value, equality, and hash behavior.

### Services

`BoardStorageService` handles SharedPreferences persistence for the board using the existing key `aac_board`.

Public behavior:

- Load the saved board if present.
- Fall back to `BoardLevel.starter()` when no saved board exists.
- Save the root board JSON using the current format.

`TtsService` wraps `FlutterTts` setup and speech behavior.

Public behavior:

- Set completion, speech rate, and pitch as today.
- Parse platform voices into `TtsVoice` values.
- Apply selected voice.
- Speak trimmed text after stopping current speech.
- Swallow unavailable-plugin and platform voice errors the same way the app does today.

`TtsService` also handles selected voice persistence using the existing key `tts_voice` and the current `TtsVoice.storageValue` format. `AacHomePage` should ask the service to load the saved voice during startup and save the selected voice after a voice change.

`PhotoStorageService` handles photo validation and saving.

Public behavior:

- Accept only JPG, JPEG, and PNG.
- Enforce the 3 MB maximum.
- Verify file signatures for JPG and PNG.
- Save copied files under the application support `aac_photos` directory.
- Return a saved path or a user-facing validation message.

The cell editor dialog can still own file picking because it is UI-driven, but file validation and saving should move to the service.

### Widgets

Move reusable widgets into focused widget files:

- `sentence_strip.dart`: sentence strip, empty prompt, undo button.
- `board_toolbar.dart`: toolbar, app icon mark, level dots.
- `aac_grid.dart`: grid and navigation cells.
- `aac_tile.dart`: AAC tile and edit cue.
- `cell_visual.dart`: symbol/photo rendering.
- `cell_editor_dialog.dart`: editor dialog, photo picker panel, photo preview.

Private helper widgets may remain private within their new files when they are only used there.

## Data Flow

App startup:

1. `main.dart` renders `TopitotApp`.
2. `TopitotApp` renders `AacHomePage` with `TopitotTheme.light`.
3. `AacHomePage` loads the board from `BoardStorageService`.
4. `AacHomePage` initializes speech through `TtsService` using the saved voice value.
5. The screen renders the toolbar, sentence strip, and AAC grid.

Cell tap:

1. In edit mode, `AacHomePage` opens `CellEditorDialog`.
2. In use mode, blank cells do nothing.
3. Folder cells push their child board onto the path.
4. Speak cells append to the sentence and call `TtsService.speak()`.

Cell edit:

1. `CellEditorDialog` edits a cloned `AacCell`.
2. Photo selection uses `PhotoStorageService` for validation and saving.
3. The dialog returns the edited cell.
4. `AacHomePage` copies changes into the existing cell and saves the root board.

Sentence speech:

1. `AacHomePage` builds sentence text from selected cells.
2. `TtsService.speak()` stops any current speech, applies the selected voice, trims text, and speaks.

## Error Handling

The refactor should preserve current failure behavior:

- Missing TTS plugin does not crash tests or unsupported environments.
- Platform voice failures are ignored when applying a listed but unavailable voice.
- Empty speech text is ignored.
- Invalid photos show clear messages in the editor dialog.
- Failed photo loading in an AAC tile shows the existing image-not-supported icon.
- Existing saved boards continue loading through the same JSON shape.

## Testing

Existing widget tests should continue to pass without changing user-facing expectations.

Refactor verification should run:

```sh
flutter analyze
flutter test
```

Optional follow-up tests can be added after the split if useful, especially for model JSON compatibility and photo validation. They are not required for this behavior-preserving refactor unless existing tests expose a gap during implementation.

## Implementation Notes

- Move code in small batches to keep diffs reviewable.
- Prefer preserving class and method names unless a name becomes misleading after extraction.
- Keep private widgets private when they are only used inside one new file.
- Do not add compatibility layers because this app does not expose a public API.
- Do not change layout constants, labels, semantics labels, keys, or preference keys unless required to compile.
- Run formatting after files are split.

## Acceptance Criteria

- `lib/main.dart` contains only app startup logic.
- AAC models, widgets, services, and constants are in focused files.
- Saved boards and saved voices remain compatible with current local data.
- Existing widget tests pass.
- `flutter analyze` passes.
- No intentional user-visible behavior changes are introduced.
