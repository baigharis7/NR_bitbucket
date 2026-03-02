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
flutter run
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

## Build

```bash
# Android APK
flutter build apk

# Android App Bundle
flutter build appbundle

# iOS (macOS only)
flutter build ios
```

## CI/CD

Bitbucket Pipelines runs automatically on every push and pull request:
- Static analysis (`flutter analyze`)
- All unit and widget tests
- Code coverage reporting
