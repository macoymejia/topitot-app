# Speech Relay by Topitot Google Play Publishing Checklist

## Release identity

- App name: `Speech Relay by Topitot`
- Android package name: `com.speechrelay.topitot.app`
- App is AAC-focused, portrait-first, and offline-first
- Version: 1.0.0+1

## Signing

- Create or reuse a release keystore outside version control
- Copy `android/key.properties.example` to `android/key.properties`
- Fill in `storePassword`, `keyPassword`, `keyAlias`, and `storeFile`
- Keep the `.jks` file out of git
- Enable Play App Signing in the Play Console

## Store listing

- Use the repo-hosted privacy policy URL: https://raw.githubusercontent.com/macoymejia/topitot-app/main/docs/legal/privacy-policy.md
- Support contact: https://github.com/macoymejia/topitot-app/issues
- Prepare short description, full description, screenshots, and feature graphic
- Confirm target audience, content rating, and Data Safety answers

## Release verification

- Run `flutter analyze`
- Run `flutter test`
- Build a signed Android App Bundle with `flutter build appbundle`
- Install and open the release build on a device before upload

## Play Console steps

1. Go to Google Play Console > All apps > Speech Relay by Topitot
2. Complete Store listing:
   - App name: Speech Relay by Topitot
   - Short description: (from listing.md)
   - Full description: (from listing.md)
3. Upload screenshots (phone and tablet)
4. Upload feature graphic
5. Set content rating (Everyone)
6. Set target audience (Children under 13)
7. Complete Data Safety section
8. Add privacy policy URL
9. Create production release
10. Upload the signed AAB file
11. Add release notes
12. Review and roll out

## Screenshots needed

- Phone: 16:9 aspect ratio (1920x1080 or similar)
- Tablet: 16:9 aspect ratio (1920x1200 or similar)
- Required screenshots:
  - Main AAC board with grid cells
  - Optional: first-use walkthrough overlay if you want to showcase onboarding
  - Edit dialog with text fields
  - Folder navigation
  - Sentence strip with selected words
