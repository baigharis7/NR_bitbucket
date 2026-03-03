# NutRenaissance Flutter

[![Build Status](https://img.shields.io/bitbucket/pipelines/Asdgvarela/nutrenaissance_flutter/master?style=flat-square)](https://bitbucket.org/Asdgvarela/nutrenaissance_flutter/pipelines)
[![Codemagic build status](https://api.codemagic.io/apps/69a5b717f42ca6f7f71af78f/69a5b717f42ca6f7f71af78e/status_badge.svg)](https://codemagic.io/app/69a5b717f42ca6f7f71af78f/69a5b717f42ca6f7f71af78e/latest_build)

A nutrition and wellness tracking Flutter application.

## Prerequisites

- Flutter SDK (stable channel)
- Dart SDK

## Getting Started

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run --flavor prod --release
```

## Testing

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# View coverage report (requires lcov)
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## Code Quality

```bash
# Static analysis
flutter analyze
```

## Flavors & Build Modes

The app uses **flavors** to separate environments and **build modes** to control runtime behavior.

### Flavors

| Flavor | App ID Suffix | Description |
|--------|--------------|-------------|
| `prod` | _(none)_ | Production — connects to live backend and Firebase. Used for all app store builds. |
| `dev` | `.dev` | Development — intended for local testing. Does not have a `google-services.json` entry, so Firebase-dependent features will not work. |

Always use `--flavor prod` when running or building the app unless you are specifically working on non-Firebase functionality.

### Build Modes

| Mode | Flag | Description |
|------|------|-------------|
| Debug | _(default)_ | Includes hot reload, debug assertions, and the DevTools banner. Used during day-to-day development. |
| Release | `--release` | Optimized, minified, and signed. No debug overhead. Used for app store builds and on-device performance testing. |

### Commands

```bash
# Run locally in debug mode
flutter run --flavor prod

# Run locally in release mode
flutter run --flavor prod --release

# Build Android APK for release
flutter build apk --release --flavor prod

# Build iOS for release (macOS only)
flutter build ipa --release
```

## CI/CD

The project uses two CI systems: **Bitbucket Pipelines** for validation and **Codemagic** for release builds.

### Bitbucket Pipelines
Runs on every **merge to master**:
- Static analysis (`flutter analyze --fatal-infos`)
- All unit and widget tests with coverage
- Coverage summary via `lcov`

### Codemagic

[Codemagic](https://codemagic.io) is a CI/CD service built for mobile apps. It handles code signing, builds for both Android and iOS on macOS machines, and produces downloadable artifacts (APK/IPA) ready for store submission.

#### PR Checks
Runs automatically on every **pull request**:
- Static analysis (`flutter analyze --fatal-infos`)
- All unit and widget tests with coverage

#### Release Builds
On every **merge to master**, two workflows run in parallel:
- **Android Release** — builds a signed APK (`app-prod-release.apk`)
- **iOS Release** — builds a signed IPA via App Store Connect

Both workflows run tests before building and produce signed artifacts automatically.

### Publishing to App Stores
Release artifacts are currently **downloaded manually** from the Codemagic build dashboard and uploaded to the Google Play Console and App Store Connect respectively. Automated publishing to the stores is not yet configured.
