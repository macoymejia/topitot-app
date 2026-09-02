# Architecture Refactor Implementation Plan

Status: Superseded by `docs/superpowers/specs/2026-08-31-next-iteration-features.md`.

This plan is historical. It targeted a behavior-preserving extraction, while the
current working tree includes intentional feature changes: portrait-only layout,
expanded starter vocabulary, reset board, and simplified platform-default TTS.

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Split the current single-file AAC app into focused app, AAC, model, service, and widget files without changing user-visible behavior.

**Architecture:** Keep `AacHomePage` as the stateful orchestration point. Move data models, constants, reusable widgets, and platform/local side effects into focused files with narrow interfaces while preserving preference keys, JSON fields, widget keys, labels, and layout behavior.

**Tech Stack:** Flutter Material 3, Dart, `flutter_tts`, `shared_preferences`, `file_picker`, `path_provider`, existing `flutter_test` widget tests.

## Global Constraints

- Preserve the same 5 by 5 board layout.
- Preserve the same starter board content.
- Preserve the same sentence strip behavior.
- Preserve the same edit mode behavior.
- Preserve the same folder navigation and maximum depth.
- Preserve the same voice selection behavior.
- Preserve the same local persistence keys: `aac_board` and `tts_voice`.
- Preserve the same photo selection, validation, and storage behavior.
- Do not add a state management package.
- Do not change saved preference keys or JSON field names.
- Do not redesign the board or toolbar.
- Do not commit changes unless the user explicitly requests a commit.

---

## File Structure

- Create `lib/app/topitot_app.dart`: owns `TopitotApp` and app-level Material setup.
- Modify `lib/main.dart`: only imports Flutter and `TopitotApp`, then calls `runApp`.
- Create `lib/aac/constants/aac_constants.dart`: owns board and photo constants.
- Create `lib/aac/models/aac_cell.dart`: owns `AacCell`, `CellKind`, and `CellVisualType`.
- Create `lib/aac/models/board_level.dart`: owns `BoardLevel` and starter board content.
- Create `lib/aac/models/tts_voice.dart`: owns `TtsVoice`.
- Create `lib/aac/services/board_storage_service.dart`: owns board SharedPreferences persistence.
- Create `lib/aac/services/tts_service.dart`: owns `FlutterTts` setup, voice parsing, voice persistence, selected voice application, and speech.
- Create `lib/aac/services/photo_storage_service.dart`: owns photo extension validation, signature validation, size validation, and copied-photo storage.
- Create `lib/aac/widgets/sentence_strip.dart`: owns `_SentenceStrip`, `_SentenceUndoButton`, and `_EmptySentencePrompt`, renamed to public `SentenceStrip` where the screen consumes it.
- Create `lib/aac/widgets/board_toolbar.dart`: owns `BoardToolbar`, `_ToolbarIdentity`, `_LevelDots`, and `_AppIconMark`.
- Create `lib/aac/widgets/aac_grid.dart`: owns `AacGrid` and `_GridNavigationTile`.
- Create `lib/aac/widgets/aac_tile.dart`: owns `AacTile` and `_TileCue`.
- Create `lib/aac/widgets/cell_visual.dart`: owns `CellVisual`.
- Create `lib/aac/widgets/cell_editor_dialog.dart`: owns `CellEditorDialog`, `_PhotoPickerPanel`, and `_PhotoPreview`.
- Create `lib/aac/aac_home_page.dart`: owns `AacHomePage` and screen orchestration after extracted code is removed from `main.dart`.
- Modify `test/widget_test.dart`: update imports if constants or `TopitotApp` move out of `main.dart`.
- Modify `README.md`: update the “Learning Flutter From This App” section to reflect the new file split.

---

### Task 1: Baseline Verification

**Files:**
- Read: `lib/main.dart`
- Read: `test/widget_test.dart`

**Interfaces:**
- Consumes: existing app behavior and tests.
- Produces: a known baseline before refactoring.

- [ ] **Step 1: Run analyzer**

Run: `flutter analyze`

Expected: Analyzer completes without new issues. If it reports an existing issue, record the exact output before changing code.

- [ ] **Step 2: Run tests**

Run: `flutter test`

Expected: Existing widget tests pass before refactoring begins. If a test already fails, record the exact failing test and error before changing code.

---

### Task 2: Extract App Entry And AAC Constants

**Files:**
- Create: `lib/app/topitot_app.dart`
- Create: `lib/aac/constants/aac_constants.dart`
- Modify: `lib/main.dart`
- Modify: `test/widget_test.dart`

**Interfaces:**
- Consumes: existing `TopitotApp`, `AacHomePage`, and constants from `lib/main.dart`.
- Produces: `TopitotApp`, `boardRows`, `boardColumns`, `cellsPerPage`, `maxFolderDepth`, and `maxCellPhotoBytes` at stable import paths.

- [ ] **Step 1: Create constants file**

Add `lib/aac/constants/aac_constants.dart`:

```dart
const int boardRows = 5;
const int boardColumns = 5;
const int cellsPerPage = boardRows * boardColumns;
const int maxFolderDepth = 4;
const int maxCellPhotoBytes = 3 * 1024 * 1024;
```

- [ ] **Step 2: Create app file while `AacHomePage` remains in `main.dart`**

Add `lib/app/topitot_app.dart`:

```dart
import 'package:flutter/material.dart';

import '../aac/aac_home_page.dart';
import '../theme/topitot_theme.dart';

class TopitotApp extends StatelessWidget {
  const TopitotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Topitot',
      debugShowCheckedModeBanner: false,
      theme: TopitotTheme.light,
      home: const AacHomePage(),
    );
  }
}
```

- [ ] **Step 3: Create temporary AAC screen file to keep app importable**

Move `AacHomePage` and its dependencies from `main.dart` to `lib/aac/aac_home_page.dart` in the same edit as Step 2 if direct extraction is practical. If not practical, create `lib/aac/aac_home_page.dart` by moving the whole current `main.dart` contents except `main()` and `TopitotApp`, then remove duplicated constants and import `constants/aac_constants.dart`.

The resulting `lib/aac/aac_home_page.dart` starts with these imports, plus any imports still required by the moved code:

```dart
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import 'constants/aac_constants.dart';
```

- [ ] **Step 4: Reduce `main.dart` to startup only**

Replace `lib/main.dart` with:

```dart
import 'package:flutter/material.dart';

import 'app/topitot_app.dart';

void main() {
  runApp(const TopitotApp());
}
```

- [ ] **Step 5: Update tests for moved exports**

Update `test/widget_test.dart` imports:

```dart
import 'package:topitot_app/aac/constants/aac_constants.dart';
import 'package:topitot_app/app/topitot_app.dart';
```

Remove `import 'package:topitot_app/main.dart';`.

- [ ] **Step 6: Format and verify this task**

Run: `dart format lib test`

Run: `flutter test`

Expected: Tests pass with no user-visible behavior changes.

---

### Task 3: Extract Models And Board Storage

**Files:**
- Create: `lib/aac/models/aac_cell.dart`
- Create: `lib/aac/models/board_level.dart`
- Create: `lib/aac/models/tts_voice.dart`
- Create: `lib/aac/services/board_storage_service.dart`
- Modify: `lib/aac/aac_home_page.dart`

**Interfaces:**
- Consumes: current `AacCell`, `BoardLevel`, and `TtsVoice` definitions.
- Produces: model classes importable by screen, widgets, services, and tests.
- Produces: `BoardStorageService.loadBoard(): Future<BoardLevel>` and `BoardStorageService.saveBoard(BoardLevel board): Future<void>`.

- [ ] **Step 1: Extract `TtsVoice`**

Create `lib/aac/models/tts_voice.dart` with the existing `TtsVoice` implementation and this import:

```dart
import 'dart:convert';
```

Keep the public constructor and members:

```dart
class TtsVoice {
  const TtsVoice({required this.name, required this.locale});

  final String name;
  final String locale;

  String get label;
  String get storageValue;

  @override
  bool operator ==(Object other);

  @override
  int get hashCode;
}
```

- [ ] **Step 2: Extract `AacCell` and enums**

Create `lib/aac/models/aac_cell.dart` with imports:

```dart
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import 'board_level.dart';
```

Move `CellKind`, `CellVisualType`, and `AacCell` from `aac_home_page.dart`. Keep the factory constructors, getters, `clone()`, `copyFrom()`, and `toJson()` behavior unchanged.

- [ ] **Step 3: Extract `BoardLevel`**

Create `lib/aac/models/board_level.dart` with imports:

```dart
import '../../theme/app_colors.dart';
import '../constants/aac_constants.dart';
import 'aac_cell.dart';
```

Move `BoardLevel` from `aac_home_page.dart`. Keep `blank`, `starter`, `fromJson`, `toJson`, and `_normalizeCells` behavior unchanged.

- [ ] **Step 4: Resolve model circular import safely**

Because `AacCell` refers to `BoardLevel` and `BoardLevel` creates `AacCell`, keep both files as library imports only if Dart accepts the cycle. If analyzer rejects the cycle, merge `AacCell`, enums, and `BoardLevel` into one file at `lib/aac/models/board_models.dart`, then export it through both planned filenames:

```dart
export 'board_models.dart';
```

Use the split only if it compiles cleanly.

- [ ] **Step 5: Add board storage service**

Create `lib/aac/services/board_storage_service.dart`:

```dart
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/board_level.dart';

class BoardStorageService {
  static const String boardKey = 'aac_board';

  Future<BoardLevel> loadBoard() async {
    final prefs = await SharedPreferences.getInstance();
    final savedBoard = prefs.getString(boardKey);
    if (savedBoard == null) {
      return BoardLevel.starter();
    }

    return BoardLevel.fromJson(jsonDecode(savedBoard) as Map<String, dynamic>);
  }

  Future<void> saveBoard(BoardLevel board) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(boardKey, jsonEncode(board.toJson()));
  }
}
```

- [ ] **Step 6: Wire `AacHomePage` to extracted models and board storage**

In `lib/aac/aac_home_page.dart`, add fields:

```dart
final BoardStorageService _boardStorage = BoardStorageService();
```

Replace board loading in `_loadApp()` with:

```dart
_root = await _boardStorage.loadBoard();
```

Replace `_saveBoard()` body with:

```dart
await _boardStorage.saveBoard(_root);
```

Remove model class definitions from `aac_home_page.dart` after imports compile.

- [ ] **Step 7: Format and verify this task**

Run: `dart format lib test`

Run: `flutter test`

Expected: Tests pass and saved board JSON keys remain unchanged.

---

### Task 4: Extract TTS And Photo Services

**Files:**
- Create: `lib/aac/services/tts_service.dart`
- Create: `lib/aac/services/photo_storage_service.dart`
- Modify: `lib/aac/aac_home_page.dart`
- Modify: `lib/aac/widgets/cell_editor_dialog.dart` if Task 5 has already moved the dialog, otherwise modify the dialog still inside `aac_home_page.dart`.

**Interfaces:**
- Consumes: current `_setupSpeech`, `_parseVoices`, `_applySelectedVoice`, `_saveVoice`, `_speak`, `_normalizedPhotoExtension`, `_matchesPhotoFormat`, and `_savePhotoBytes` behavior.
- Produces: `TtsSetupResult`, `TtsService.setup(String? savedVoice): Future<TtsSetupResult>`, `TtsService.applySelectedVoice(TtsVoice? voice): Future<void>`, `TtsService.saveVoice(TtsVoice? voice): Future<void>`, `TtsService.loadSavedVoiceValue(): Future<String?>`, and `TtsService.speak(String text, TtsVoice? selectedVoice): Future<void>`.
- Produces: `PhotoStorageResult`, `PhotoStorageService.validateAndSavePickedFile(PlatformFile file): Future<PhotoStorageResult>`.

- [ ] **Step 1: Add TTS service result type and service**

Create `lib/aac/services/tts_service.dart` with imports:

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/tts_voice.dart';
```

Define:

```dart
class TtsSetupResult {
  const TtsSetupResult({required this.voices, required this.selectedVoice});

  final List<TtsVoice> voices;
  final TtsVoice? selectedVoice;
}

class TtsService {
  TtsService({FlutterTts? flutterTts}) : _tts = flutterTts ?? FlutterTts();

  static const String voiceKey = 'tts_voice';
  final FlutterTts _tts;

  Future<String?> loadSavedVoiceValue() async;
  Future<TtsSetupResult> setup(String? savedVoice) async;
  List<TtsVoice> parseVoices(dynamic voicesResult);
  Future<void> applySelectedVoice(TtsVoice? voice) async;
  Future<void> saveVoice(TtsVoice? voice) async;
  Future<void> speak(String text, TtsVoice? selectedVoice) async;
}
```

Use the existing method bodies from `AacHomePage`. Preserve speech rate `0.45`, pitch `1.0`, `awaitSpeakCompletion(true)`, `debugPrint` messages, and PlatformException handling.

- [ ] **Step 2: Wire `AacHomePage` to TTS service**

Add field:

```dart
final TtsService _ttsService = TtsService();
```

Replace saved voice loading in `_loadApp()` with:

```dart
final savedVoice = await _ttsService.loadSavedVoiceValue();
```

Replace `_setupSpeech(savedVoice)` with:

```dart
final speech = await _ttsService.setup(savedVoice);
_voices = speech.voices;
_selectedVoice = speech.selectedVoice;
```

Replace `_applySelectedVoice()`, `_saveVoice()`, and `_speak(String text)` calls with service calls. Keep wrapper methods only if they keep the screen code simpler.

- [ ] **Step 3: Add photo storage result and service**

Create `lib/aac/services/photo_storage_service.dart` with imports:

```dart
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../constants/aac_constants.dart';
```

Define:

```dart
class PhotoStorageResult {
  const PhotoStorageResult._({this.path, this.error});

  const PhotoStorageResult.saved(String path) : this._(path: path);
  const PhotoStorageResult.failed(String error) : this._(error: error);

  final String? path;
  final String? error;
  bool get isSaved => path != null;
}

class PhotoStorageService {
  Future<PhotoStorageResult> validateAndSavePickedFile(PlatformFile file) async;
  String? normalizedPhotoExtension(String name);
  bool matchesPhotoFormat(Uint8List bytes, String extension);
  Future<String> savePhotoBytes(Uint8List bytes, String extension) async;
}
```

Move the existing validation messages exactly:

```text
Please choose a JPG or PNG photo.
Photo must be 3 MB or smaller.
Could not read that photo.
Please choose a real JPG or PNG photo.
```

- [ ] **Step 4: Wire editor photo flow to photo service**

Add a `PhotoStorageService` to `CellEditorDialog` or `_CellEditorDialogState`:

```dart
final PhotoStorageService _photoStorage = PhotoStorageService();
```

Replace photo validation and saving inside `_pickPhoto()` with:

```dart
final saved = await _photoStorage.validateAndSavePickedFile(file);
if (!mounted) {
  return;
}
if (!saved.isSaved) {
  setState(() => _photoError = saved.error);
  return;
}
setState(() {
  _visualType = CellVisualType.photo;
  _photoPath = saved.path;
  _photoError = null;
});
```

Remove photo helper methods from the dialog after imports compile.

- [ ] **Step 5: Format and verify this task**

Run: `dart format lib test`

Run: `flutter test`

Expected: Tests pass. TTS tests still work with the existing `flutter_tts` method channel mock.

---

### Task 5: Extract Reusable AAC Widgets

**Files:**
- Create: `lib/aac/widgets/sentence_strip.dart`
- Create: `lib/aac/widgets/board_toolbar.dart`
- Create: `lib/aac/widgets/aac_grid.dart`
- Create: `lib/aac/widgets/aac_tile.dart`
- Create: `lib/aac/widgets/cell_visual.dart`
- Create: `lib/aac/widgets/cell_editor_dialog.dart`
- Modify: `lib/aac/aac_home_page.dart`

**Interfaces:**
- Consumes: widget classes currently defined in `aac_home_page.dart`.
- Produces: public widgets consumed by `AacHomePage`: `SentenceStrip`, `BoardToolbar`, `AacGrid`, `AacTile`, `CellVisual`, and `CellEditorDialog`.

- [ ] **Step 1: Extract `CellVisual` first**

Create `lib/aac/widgets/cell_visual.dart` with the existing `_CellVisual` implementation renamed to `CellVisual`.

Constructor signature:

```dart
const CellVisual({
  super.key,
  required this.cell,
  required this.fit,
  required this.borderRadius,
  required this.textStyle,
});
```

Keep `Image.file`, `File(cell.photoPath!)`, `errorBuilder`, and symbol rendering unchanged.

- [ ] **Step 2: Extract sentence widgets**

Create `lib/aac/widgets/sentence_strip.dart`. Rename `_SentenceStrip` to `SentenceStrip`. Keep `_SentenceUndoButton` and `_EmptySentencePrompt` private.

Constructor signature:

```dart
const SentenceStrip({
  super.key,
  required this.sentence,
  required this.onSpeak,
  required this.onClear,
  required this.onRemoveLast,
});
```

Keep `ValueKey<String>('sentence-word-area')`, button labels, semantics, tooltip text, chip styling, and all layout values unchanged.

- [ ] **Step 3: Extract toolbar widgets**

Create `lib/aac/widgets/board_toolbar.dart`. Rename `_BoardToolbar` to `BoardToolbar`. Keep helper widgets private.

Constructor signature:

```dart
const BoardToolbar({
  super.key,
  required this.title,
  required this.depth,
  required this.editMode,
  required this.expanded,
  required this.voices,
  required this.selectedVoice,
  required this.onExpandedChanged,
  required this.onEditModeChanged,
  required this.onVoiceChanged,
});
```

Keep toolbar height, labels, tooltips, and edit/use toggle behavior unchanged.

- [ ] **Step 4: Extract tile and grid widgets**

Create `lib/aac/widgets/aac_tile.dart`. Rename `_AacTile` to `AacTile` and keep `_TileCue` private.

Create `lib/aac/widgets/aac_grid.dart`. Rename `_AacGrid` to `AacGrid` and keep `_GridNavigationTile` private.

Keep keys unchanged:

```dart
const ValueKey<String>('grid-back-cell')
const ValueKey<String>('grid-home-cell')
ValueKey<String>('aac-cell-$index')
```

- [ ] **Step 5: Extract cell editor dialog**

Create `lib/aac/widgets/cell_editor_dialog.dart`. Move `CellEditorDialog`, `_CellEditorDialogState`, `_PhotoPickerPanel`, and `_PhotoPreview`.

Constructor signature remains:

```dart
const CellEditorDialog({super.key, required this.cell, required this.depth});
```

Keep dialog title, text field labels, helper text, button labels, photo messages, and folder switch copy unchanged.

- [ ] **Step 6: Update `AacHomePage` widget references**

Replace private widget names in `lib/aac/aac_home_page.dart`:

```dart
BoardToolbar(...)
SentenceStrip(...)
AacGrid(...)
CellEditorDialog(...)
```

Remove extracted widget classes from `aac_home_page.dart`.

- [ ] **Step 7: Format and verify this task**

Run: `dart format lib test`

Run: `flutter test`

Expected: Existing widget tests pass with the same finders and keys.

---

### Task 6: Final Cleanup, Documentation, And Full Verification

**Files:**
- Modify: `lib/aac/aac_home_page.dart`
- Modify: `README.md`
- Read: `docs/superpowers/specs/2026-08-17-architecture-refactor-design.md`

**Interfaces:**
- Consumes: extracted app structure from prior tasks.
- Produces: clean architecture matching the approved spec and passing verification.

- [ ] **Step 1: Remove unused imports and dead code**

In `lib/aac/aac_home_page.dart`, remove imports that are no longer needed after extraction, such as direct `dart:convert`, `dart:io`, `file_picker`, `path_provider`, `shared_preferences`, or `flutter_tts` imports when services/widgets own those dependencies.

Keep imports needed by the screen:

```dart
import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import 'constants/aac_constants.dart';
import 'models/aac_cell.dart';
import 'models/board_level.dart';
import 'models/tts_voice.dart';
import 'services/board_storage_service.dart';
import 'services/tts_service.dart';
import 'widgets/aac_grid.dart';
import 'widgets/board_toolbar.dart';
import 'widgets/cell_editor_dialog.dart';
import 'widgets/sentence_strip.dart';
```

- [ ] **Step 2: Update README file map**

Replace the current “Learning Flutter From This App” file list with references to:

```text
lib/main.dart starts Flutter and renders TopitotApp.
lib/app/topitot_app.dart defines the Material app and theme.
lib/aac/aac_home_page.dart coordinates board state, sentence state, navigation, speech, and editing.
lib/aac/models/ contains the local AAC data models.
lib/aac/services/ contains local persistence, text-to-speech, and photo storage helpers.
lib/aac/widgets/ contains the sentence strip, toolbar, grid, tile, visual, and cell editor UI.
lib/theme/ contains design tokens and the Material theme.
```

- [ ] **Step 3: Run formatter**

Run: `dart format lib test`

Expected: Formatter completes successfully.

- [ ] **Step 4: Run analyzer**

Run: `flutter analyze`

Expected: No analyzer issues.

- [ ] **Step 5: Run full test suite**

Run: `flutter test`

Expected: All widget tests pass.

- [ ] **Step 6: Inspect diff for behavior changes**

Run: `git diff -- lib test README.md docs/superpowers/specs docs/superpowers/plans`

Confirm the diff only moves code, wires extracted services/widgets, updates imports, and updates README architecture notes. Confirm there are no intentional changes to labels, keys, constants, persistence keys, JSON field names, starter board content, or layout behavior.
