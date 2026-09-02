# Transparent Launch Splash Design

## Context

Speech Relay by Topitot is a child-friendly AAC app that already launches into a portrait-first home screen. The request is for a transparent launch screen that appears only when the app starts, shows the provided Speech Relay artwork, and disappears automatically after 3 seconds.

The app already has a Flutter entry point in `lib/main.dart` and a `MaterialApp` wrapper in `lib/app/topitot_app.dart`, which makes the app shell the safest place to manage a one-time launch overlay.

## Goal

Show a transparent splash overlay on app launch, centered on the provided Speech Relay artwork, then hide it automatically after 3 seconds without any extra navigation.

## Non-Goals

- No new onboarding flow.
- No persistent launch preference.
- No changes to AAC board behavior.
- No changes to the native Android or iOS splash screens beyond keeping them functional.

## Recommended Approach

Use a Flutter overlay inside `TopitotApp` rather than a separate route or a native-only splash. The app shell can render the AAC home screen immediately and layer a transparent launch panel above it, then remove that panel after a timer fires.

This keeps the feature simple, cross-platform, and easy to test. It also avoids a second navigation stack and avoids platform-specific splash behavior that is harder to keep transparent.

## File Structure

```text
lib/
  app/
    topitot_app.dart
    widgets/
      launch_splash_overlay.dart
assets/
  images/
    launch/
      speech_relay_launch.png
pubspec.yaml
```

## Components

### `TopitotApp`

`TopitotApp` becomes responsible for showing the one-time launch overlay. It keeps the existing `MaterialApp` setup, AAC home screen, and theme, but wraps the home page in a stack that can display the splash panel above it.

### `LaunchSplashOverlay`

`LaunchSplashOverlay` is a small widget that:

- fills the screen with a transparent background,
- centers the provided launch artwork,
- optionally uses a short fade-out when hiding,
- exposes a `visible` flag so `TopitotApp` controls when it disappears.

### Asset registration

The provided image should be added as a Flutter asset and referenced from the overlay. The asset path should be stable and obvious so it can be reused later if needed.

## Data Flow

1. App starts and `TopitotApp` builds normally.
2. The AAC home screen is present behind the overlay from the beginning.
3. `LaunchSplashOverlay` is shown immediately.
4. A 3-second timer flips the overlay off.
5. The app remains on the AAC home screen with no route change.

## Error Handling

- If the launch asset is missing or fails to load, the app should still open the AAC home screen.
- The splash should fail closed, not block startup.
- The overlay timer must be cancelled if the widget is disposed before the 3 seconds expire.

## Testing

- Verify the launch overlay is visible on first build.
- Verify it disappears after 3 seconds.
- Verify the AAC home screen remains available underneath it.
- Verify disposing the widget before the timer completes does not throw.

## Acceptance Criteria

- The splash is only shown on app launch.
- The splash is transparent rather than an opaque full-screen page.
- The Speech Relay artwork is centered and visible during the splash.
- The splash hides automatically after 3 seconds.
- The AAC home screen is still the destination after the splash disappears.
