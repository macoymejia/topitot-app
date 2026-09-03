# Prepare Google Play Build Design

## Context

Google Play rejects release uploads when the Android `versionCode` is not strictly higher than the latest uploaded one. This project already uses Flutter versioning, where the build number in `pubspec.yaml` maps to Android `versionCode`.

The user wants a single command named `prepare google play build` that prepares a release bundle for closed testing with the least possible manual work.

## Goal

Create a reusable opencode command that automatically bumps the Flutter build number, runs tests, builds the Android App Bundle, and reports the upload path.

## Non-Goals

- No Play Console API integration.
- No automatic upload to Google Play.
- No changes to app runtime behavior.

## Recommended Approach

Use an opencode command in `.opencode/command/prepare-google-play-build.md`. A command is the lightest fit for a fixed release-prep routine and keeps the workflow token-cheap.

The command should instruct the build agent to edit `pubspec.yaml`, increment the build number by one, run `flutter test`, then run `flutter build appbundle` and summarize the result.

## File Structure

```text
.opencode/
  command/
    prepare-google-play-build.md
pubspec.yaml
```

## Components

### Command file

The command file defines the shortcut and its fixed routine. It should be discoverable by opencode and readable as a short, task-oriented prompt.

### `pubspec.yaml`

`pubspec.yaml` remains the source of truth for the Flutter version name and build number. The command increments the build number there before building.

## Data Flow

1. Command runs.
2. The agent reads `pubspec.yaml`.
3. The build number is incremented by one.
4. Tests run.
5. The Android App Bundle is built.
6. The command reports the bundle path and the upload reminder.

## Error Handling

- If `pubspec.yaml` cannot be read or parsed, stop and report the issue.
- If `flutter test` fails, stop before building.
- If `flutter build appbundle` fails, stop and report the failure.

## Testing

- Run the command once and verify it updates `pubspec.yaml` correctly.
- Verify `flutter test` passes.
- Verify `flutter build appbundle` produces `build/app/outputs/bundle/release/app-release.aab`.

## Acceptance Criteria

- The command is available as `prepare google play build`.
- The build number increases automatically each time the command runs.
- The command runs tests before building.
- The command produces a release AAB.
- The command reports the exact upload path and next manual step.
