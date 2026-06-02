# Topitot AAC

Topitot AAC is a Flutter-based augmentative and alternative communication app
prepared for iPad use. It helps children and people with speech difficulties
build a sentence by tapping visual communication cells, then play the selected
words using the system text-to-speech voices available on iPadOS.

## Current Features

- Offline-first Flutter app for iOS/iPadOS and Android.
- AAC board with 3 rows by 6 columns.
- Folder-style navigation up to 4 levels deep.
- Customizable cells with displayed word, spoken text, symbol, color, and
  folder/speech behavior.
- Sentence strip at the top with play, remove-last, and clear controls.
- Back button on the top-right side of the board controls.
- System voice selector powered by installed platform voices.
- Local persistence through `shared_preferences`.

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

The most important file is `lib/main.dart`.

- `main()` starts Flutter and renders `TopitotApp`.
- `TopitotApp` defines the app theme and first screen.
- `AacHomePage` is a `StatefulWidget` because the selected sentence, current
  folder level, voice, and edit mode can change.
- `_SentenceStrip` renders the upper selected-words area.
- `_BoardToolbar` renders the board title, depth, voice picker, edit toggle,
  and back button.
- `_AacGrid` renders the fixed 3 by 6 AAC grid.
- `_AacTile` renders one communication cell.
- `BoardLevel` and `AacCell` are the app's simple local data models.

The key Flutter pattern is this:

```dart
setState(() {
  _sentence.add(cell);
});
```

When state changes, Flutter reruns `build()` and updates the screen.

## Offline Notes

The app stores board customization locally and does not require internet access
for normal use. Speech playback depends on voices installed on the device. On
iPadOS, the voice selector reads the system voices exposed by the platform.
