# Speech Relay by Topitot Google Play Publishing Checklist

## Release identity

- App name: `Speech Relay by Topitot`
- Android package name: `com.topitot.speechrelay`
- App is AAC-focused, portrait-first, and offline-first

## Signing

- Create or reuse a release keystore outside version control
- Copy `android/key.properties.example` to `android/key.properties`
- Fill in `storePassword`, `keyPassword`, `keyAlias`, and `storeFile`
- Keep the `.jks` file out of git
- Enable Play App Signing in the Play Console

## Store listing

- Use the repo-hosted privacy policy URL
- Support contact: `https://github.com/macoymejia/topitot-app/issues`
- Prepare short description, full description, screenshots, and feature graphic
- Confirm target audience, content rating, and Data Safety answers

## Release verification

- Run `flutter analyze`
- Run `flutter test`
- Build a signed Android App Bundle with `flutter build appbundle`
- Install and open the release build on a device before upload
