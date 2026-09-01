# Topitot AAC

Topitot AAC is a Flutter-based augmentative and alternative communication app
prepared for portrait tablet and phone use. It helps children and people with
speech difficulties build a sentence by tapping visual communication cells, then
play the selected words using the device text-to-speech engine.

## Current Features

- Offline-first Flutter app for iOS/iPadOS and Android.
- Portrait-first AAC experience for predictable child-friendly reach zones.
- AAC board with 5 rows by 5 columns.
- Back and Home navigation cells reserved inside the grid.
- Expanded starter vocabulary for core words, food, people, actions, feelings,
  and places.
- Folder-style navigation up to 4 levels deep.
- Customizable cells with displayed word, spoken text, symbol, color, and
  folder/speech behavior.
- Custom photos for cells with JPG/PNG validation and local copied storage.
- Sentence strip at the top with speak, remove-last, and clear controls.
- Reset action to restore the optimized starter board.
- Local board persistence through `shared_preferences`.

## Run The App

```sh
flutter pub get
flutter run
```

For an iPad simulator, open Simulator first or choose the device in your IDE,
then run:

```sh
flutter devices
flutter run -d <device-id>
```

## Verify The Project

```sh
flutter analyze
flutter test
```

## Learning Flutter From This App

The app is split into focused files so each part is easier to understand.

- `lib/main.dart` starts Flutter and renders `TopitotApp`.
- `lib/app/topitot_app.dart` defines the Material app and theme.
- `lib/aac/aac_home_page.dart` coordinates board state, sentence state,
  navigation, speech, and editing.
- `lib/aac/models/` contains the local AAC data models.
- `lib/aac/services/` contains local persistence, text-to-speech, and photo
  storage helpers.
- `lib/aac/widgets/` contains the sentence strip, toolbar, grid, tile, visual,
  and cell editor UI.
- `lib/theme/` contains design tokens and the Material theme.

The key Flutter pattern is this:

```dart
setState(() {
  _sentence.add(cell);
});
```

When state changes, Flutter reruns `build()` and updates the screen.

## Offline Notes

The app stores board customization locally and does not require internet access
for normal use. Speech playback depends on the text-to-speech support installed
on the device. The app currently uses the platform default voice instead of
exposing a child-facing voice selector.

## Next Iteration Notes

- Keep the main AAC board simple and portrait-first unless a specific classroom
  or accessibility need requires responsive landscape behavior.
- Treat `BoardLevel.starter()` as the source of truth for default vocabulary.
- If voice customization returns, place it behind caregiver settings instead of
  the child-facing toolbar.
- Add focused tests when changing starter vocabulary, reset behavior, photo
  validation, or orientation behavior.
