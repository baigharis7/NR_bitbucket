# NutRenaissance — Tech Stack

A technical explanation of every tool and library used in this project: what it is, its philosophy, and why it was chosen here.

---

## Table of Contents

1. [Core Language & Framework](#1-core-language--framework)
2. [State Management](#2-state-management)
3. [Local Storage](#3-local-storage)
4. [Authentication](#4-authentication)
5. [AWS Cloud Backend](#5-aws-cloud-backend)
6. [Firebase Services](#6-firebase-services)
7. [Device Integration](#7-device-integration)
8. [Food Recognition & Scanning](#8-food-recognition--scanning)
9. [Networking](#9-networking)
10. [UI Libraries](#10-ui-libraries)
11. [Internationalization](#11-internationalization)
12. [Code Generation](#12-code-generation)
13. [Testing](#13-testing)
14. [CI/CD & Developer Tools](#14-cicd--developer-tools)

---

## 1. Core Language & Framework

### Dart

**Language:** Dart (Google, 2011)  
**Philosophy:** A compiled, strongly-typed, object-oriented language designed for client applications. Compiles to native ARM code (mobile), JavaScript (web), or runs in a VM during development for hot reload. Its type system is sound — the compiler catches most errors before runtime. Supports both AOT (Ahead-Of-Time) compilation for release builds and JIT (Just-In-Time) for development.

**Why here:** Dart is the only language Flutter supports. It was designed together with Flutter and reflects the same philosophy: fast startup, predictable performance, and developer ergonomics above all.

**Key Dart features used in this project:**
- `async/await` — all API calls and local DB operations are async
- `Stream` — used by DashboardEventBus and BLoC for reactive data flow
- Null safety (`?`, `!`, `??`) — enforced since Dart 2.12; force-unwraps (`!.`) are still widespread across `lib/` and represent places where null safety is bypassed (a recurring crash source — see the profile-mapper null-safe sweep of June 2026)
- Extension methods — used to add utility functions to existing types

---

### Flutter

**Language:** Dart  
**Philosophy:** Flutter (Google, 2018) is a UI framework where every pixel is drawn by Flutter itself, not by the native platform. It does not use native UI components (like UIKit on iOS or Android Views) — instead it has its own rendering engine (Skia/Impeller). This means pixel-perfect consistency across platforms, but also that the app carries its own rendering stack.

The core mental model: **everything is a widget**. The UI is a tree of composable, immutable widgets. State changes cause the tree to rebuild. There is no XML layout or separate template language — UI is code.

**Why here:** Single codebase for Android and iOS, sharing 100% of business logic and ~95% of UI. The app targets both platforms with identical behaviour and appearance. Flutter 3.x (pinned to 3.32.8 via FVM) is the stable production release used here.

**Build flavors used:** `prod` (production, with Firebase) and `dev` (development, Firebase non-functional). Always run and build with `--flavor prod`.

---

## 2. State Management

### flutter_bloc (BLoC Pattern)

**Package:** `flutter_bloc ^9.1.1`  
**Language:** Dart  
**Philosophy:** BLoC (Business Logic Component) is an architectural pattern that separates UI from business logic using streams. The UI sends **events** (user actions) into a BLoC; the BLoC processes them and emits new **states**; the UI rebuilds reactively in response to state changes. No direct UI-to-logic coupling.

```
UI → adds Event → BLoC → processes → emits State → UI rebuilds
```

The `flutter_bloc` package implements this pattern on top of Dart streams with a clean API. It enforces a strict unidirectional data flow, making the app behaviour predictable and testable.

**Why here:** The app has 50+ BLoCs, each owning one screen or logical unit (dashboard, food event form, profile, etc.). BLoC makes it easy to test each piece of logic independently (see `test/bloc/`), and the `DashboardEventBus` coordinates between BLoCs reactively without coupling them directly.

---

### flutter_hooks

**Package:** `flutter_hooks ^0.21.3`  
**Language:** Dart  
**Philosophy:** A port of React Hooks to Flutter. Hooks let you reuse stateful logic across widgets without creating a full `StatefulWidget`. Common hooks: `useState`, `useEffect`, `useTextEditingController`, `useAnimationController`.

**Why here:** Used selectively in screens where a small amount of local UI state (like a form controller or animation) is needed without the overhead of a full `StatefulWidget` or a dedicated BLoC.

---

## 3. Local Storage

### Hive

**Package:** `hive ^2.1.0` + `hive_flutter ^1.1.0`  
**Language:** Dart (Hive itself is pure Dart)  
**Philosophy:** A lightweight, fast NoSQL key-value store written entirely in Dart. Data is serialized using a binary format (more compact and faster than JSON). Each "box" is a typed collection. Hive is designed to be simple: you open a box, read/write typed objects, close it. No SQL, no schema migrations for simple changes.

Hive uses **TypeAdapters** — generated Dart classes that tell Hive how to serialize/deserialize each custom object. The `build_runner` tool generates these adapters from annotated model classes.

**Why here:** 30+ Hive boxes are used as the primary offline store for all events (food, sport, liquid, supplement, feces, urine, sleep, steps), routines, favorites, master data, and the sync queue. Writes are synchronous and instant, which is what makes the offline-first architecture feel responsive — the user never waits for a network round-trip to see their data saved.

---

### Drift (formerly Moor)

**Package:** `drift ^2.14.0` + `drift_dev ^2.14.0`  
**Language:** Dart (Drift is a Dart ORM over SQLite)  
**Philosophy:** Drift is a type-safe, reactive SQL library for Dart/Flutter built on top of SQLite. You define your schema in Dart, and Drift generates all the query code, DAOs (Data Access Objects), and type-safe result classes. It supports reactive queries — a stream that emits new results whenever the underlying data changes.

The philosophy is to bring the power of SQL (joins, filtering, aggregation) to Flutter while keeping everything type-safe and testable.

**Why here:** Used for the `ReferenceDatabase` (schema v3), which stores data that benefits from SQL queries: NutrientCompositions (~1800 foods with 116+ nutrient fields per food), SportMets (~800 entries), NutrientLosses, CookingMethodOils, and versioned blobs. This data is too structured and too large for Hive's key-value model.

**6 tables:** `NutrientCompositions`, `NutrientLosses`, `CookingMethodOils`, `SportMets`, `ReferenceDataVersions`, `ReferenceDataBlobs`

---

### SharedPreferences

**Package:** `shared_preferences ^2.0.13`  
**Language:** Dart (wraps native iOS NSUserDefaults / Android SharedPreferences)  
**Philosophy:** The simplest possible key-value store for primitive data. Backed by the platform's native preferences system. Synchronous reads, async writes. Not suitable for large data or complex objects.

**Why here:** Stores small, frequently-accessed values: `userId`, auth tokens, token expiry timestamp, master file version numbers, and feature flags. These need to survive app restarts but don't need the overhead of Hive or Drift.

---

## 4. Authentication

### AWS Cognito

**Service:** Amazon Cognito (AWS managed service)  
**Philosophy:** Cognito is a fully managed user identity service. It handles user registration, login, email verification, password reset, and token management. The app uses the `USER_SRP_AUTH` flow (Secure Remote Password) — passwords are never sent to the server in plain text; a cryptographic protocol proves knowledge of the password without transmitting it.

Cognito issues three tokens on login: **ID Token** (who the user is, used as the API auth header), **Access Token** (what the user can do), and **Refresh Token** (renew expired tokens without re-login).

**Why here:** Managed auth means no server code for registration, login, email verification, or token rotation. The app auto-refreshes the ID Token before every API call (decoded with `jwt_decoder` to check expiry).

| Environment | User Pool | Client ID |
|-------------|-----------|-----------|
| Prod | `eu-west-3_sZA2GWT5W` | `d1lt020mqpfmkq1vkkm0dsgpd` |
| Dev | `eu-west-3_ewIR3R9Sl` | `729e89vrtssaguuv0hpdkhs1eg` |

---

### Amplify Flutter SDK

**Package:** `amplify_flutter ^2.6.5` + `amplify_auth_cognito ^2.6.5`  
**Language:** Dart  
**Philosophy:** Amplify is AWS's official client SDK for mobile/web apps. It provides a high-level API over AWS services. Here only the `Auth` category is used (wrapping Cognito). Amplify is initialized once at app startup with the Cognito pool configuration.

**Why here:** The recommended way to interact with Cognito from Flutter. Handles the SRP authentication flow, token storage, and session management without custom crypto code.

---

### jwt_decoder

**Package:** `jwt_decoder ^2.0.1`  
**Language:** Dart  
**Philosophy:** A small utility to decode JWT (JSON Web Tokens) without verifying the signature. Used to read the payload — specifically the `exp` (expiry) field.

**Why here:** Before every API call, the app decodes the stored ID Token to check if it has expired. If it has, it refreshes via Cognito before making the request. This keeps all API calls authenticated without relying on getting a 401 error from the server.

---

## 5. AWS Cloud Backend

The entire backend is **serverless** — no servers to manage, no always-on processes. AWS manages provisioning, scaling, and availability.

### AWS Lambda

**Language:** Node.js 20.x (backend functions)  
**Philosophy:** Lambda is a Function-as-a-Service platform. You upload a function; AWS runs it in response to events (HTTP requests, schedules, triggers). You pay only for execution time — there is no cost when nobody is using the app. Each Lambda is independent, stateless, and short-lived.

**Why here:** 40+ Lambda functions handle all backend logic — persisting events to DynamoDB, managing EventBridge schedules for routines, sending FCM notifications, and bidirectional sync. Since March 2026, most computation (nutrient calculation, sport kcal, BMR/RDA) was moved client-side to Dart, so the remaining Lambdas are mostly simple write operations.

---

### AWS API Gateway

**Philosophy:** A managed HTTP gateway that acts as the single entry point for all app-to-backend communication. Routes each REST endpoint (`/food-event`, `/profile`, `/events-sync-test`, etc.) to the corresponding Lambda function. Handles HTTPS termination, throttling, and auth token validation.

**Why here:** All API calls from the Flutter app go through API Gateway. There are two environments: prod (`05kpv2341k.execute-api.eu-west-3.amazonaws.com/prod`) and dev (`8bymr2h348.execute-api.eu-west-3.amazonaws.com/dev`).

---

### AWS DynamoDB

**Philosophy:** DynamoDB is a fully managed NoSQL key-value and document database. It scales automatically (in on-demand mode), has single-digit millisecond latency, and requires no schema migrations. Every table has a **partition key** (here: `userId`) and an optional **sort key** (here: `eventId` or `eventDate`). There are no joins — data is modelled to be accessed by its primary key.

**Why here:** 21 production tables, one per event category. The data model maps naturally to DynamoDB: each user's events are isolated by `userId`, and individual events are retrieved by `eventId`. The app never queries across users.

**Known issue:** Some tables are still in **provisioned mode at 1 WCU** (1 write/second), which will cause throttling under load. Should be migrated to **on-demand mode**.

---

### AWS S3

**Philosophy:** Simple Storage Service — object storage for files of any size. Organized in buckets. Files are addressed by bucket + key. No file system semantics, just HTTP GET/PUT.

**Why here:** Stores the master data files that the app downloads on first launch and checks for updates on each session: `nutrients.json` (~1800 foods), `sports.json` (~800 sports with METs), cooking tables, and nutrient objective data. Two buckets: `nutrients-pro` and `master-files-app-pro`.

---

### AWS EventBridge Scheduler

**Philosophy:** A managed scheduler service that invokes a Lambda at a specific time or on a cron schedule. Each schedule is an independent resource with its own timezone and target.

**Why here:** Each user routine (breakfast at 08:00 every Monday and Wednesday, for example) creates one EventBridge schedule per day of the week. When the schedule fires, it invokes a Lambda that writes the event to DynamoDB and sends an FCM push notification to the user's device. Schedule naming: `routine-{userId}-{eventId}-{dayName}`.

---

### AWS Secrets Manager

**Philosophy:** Secure storage for credentials (API keys, passwords, certificates) that should never be hardcoded. Secrets are fetched at Lambda runtime, not embedded in code.

**Why here:** Stores the Firebase Admin SDK credentials (the service account key that authorizes the backend to send FCM push notifications). The routine handler Lambda retrieves this secret at runtime to authenticate with Firebase.

---

## 6. Firebase Services

Firebase is Google's mobile development platform. NutRenaissance uses two Firebase services.

### Firebase Cloud Messaging (FCM)

**Package:** `firebase_messaging ^16.1.2`  
**Philosophy:** FCM is the cross-platform push notification infrastructure. It manages device token registration, message routing, and delivery — handling the complexity of APNs (Apple) and GCM (Google) under a single API.

NutRenaissance uses **data-only messages** (no visible notification from FCM itself) — the app receives a silent push, triggers a sync in the background, and the UI updates automatically. This is more user experience-friendly than showing a "new data available" notification.

**Why here:** When a routine fires on the backend, the app needs to know immediately so the dashboard reflects the new event. FCM is the only reliable mechanism to wake an app in the background on both iOS and Android.

---

### Firebase Crashlytics

**Package:** `firebase_crashlytics ^5.0.8`  
**Philosophy:** Crashlytics is a real-time crash reporting service. When the app crashes in production, it captures the full stack trace, device info, and session context, and sends it to the Firebase console. It also captures non-fatal errors (reported manually with `FirebaseCrashlytics.instance.recordError()`).

On iOS, Crashlytics uses **dSYM files** (debug symbol files) to map raw memory addresses in crash reports back to readable Dart/Swift function names.

**Why here:** Production crash monitoring without any server infrastructure. The team is alerted immediately when a crash occurs in a user's device, with enough context to diagnose and fix it. The `google-services.json` in `android/app/src/prod/` connects the app to the Firebase project `nutrenaissance-aab71`.

---

## 7. Device Integration

### health (Health Connect / HealthKit)

**Package:** `health ^13.1.4`  
**Philosophy:** A cross-platform abstraction over the two competing health data platforms: **Apple HealthKit** (iOS) and **Health Connect** (Android 14+, previously Google Fit). Both platforms act as a central health data hub on the device — apps request permission to read specific data types (steps, sleep, heart rate, etc.) and the platform controls access.

**Why here:** NutRenaissance reads **step count** and **sleep duration** from the device health platform to display on the dashboard. This gives users a unified view of their activity alongside their nutrition data without NutRenaissance collecting the raw health data itself.

---

### WorkManager

**Package:** `workmanager ^0.9.0`  
**Philosophy:** WorkManager (Android) / BGTaskScheduler (iOS) is the platform-recommended way to schedule background work. It respects battery optimization policies (Doze mode on Android), defers work to low-power windows, and guarantees execution even after app restarts.

**Why here:** Intended for periodic background health sync (syncing steps and sleep even when the app is closed). The implementation is **partially complete** — the WorkManager task is registered, but the Dart isolate it spawns does not re-initialize Hive, so it cannot actually write to local storage. This is a known open issue.

---

### camera

**Package:** `camera ^0.11.0`  
**Philosophy:** Flutter's official camera plugin. Provides access to the device camera with preview, capture, and exposure controls. Works on both Android (CameraX) and iOS (AVFoundation).

**Why here:** Powers the `FoodScannerScreen` — the visual food recognition feature. The user points their camera at food; the app captures a frame and sends it to LogMeal or Claude Vision for identification.

---

### permission_handler

**Package:** `permission_handler ^12.0.1`  
**Philosophy:** A unified API to request and check runtime permissions across Android and iOS. Both platforms require explicit user permission for sensitive capabilities (camera, health data, notifications). The permission_handler abstracts the platform-specific APIs for requesting and checking these permissions.

**Why here:** Used to request camera permission before the food scanner and health data permissions before the Health Connect/HealthKit integration.

---

## 8. Food Recognition & Scanning

### Google ML Kit (Barcode Scanning)

**Package:** `google_mlkit_barcode_scanning ^0.14.0`  
**Philosophy:** ML Kit is Google's on-device machine learning SDK. The barcode scanner runs entirely on-device — no internet required, no data sent externally. It detects and decodes barcodes (including QR codes) from image frames in real time.

**Why here:** First step in the food scanner pipeline. When a user captures a photo, ML Kit checks for a barcode. If found, the barcode value (EAN-13, UPC-A, etc.) is looked up in OpenFoodFacts to retrieve nutritional information without any AI recognition.

---

### OpenFoodFacts

**Service:** OpenFoodFacts (open-source food database, no package — direct HTTP call)  
**Philosophy:** A collaborative, open-source database of food products identified by barcode. Contains nutritional information for millions of packaged products worldwide. Free to use, no API key required.

**Why here:** When a barcode is detected by ML Kit, the app queries OpenFoodFacts with the barcode number to get the product's nutrition facts. The `NutrientMapperService` then maps the OpenFoodFacts fields to NutRenaissance's internal `Params` model.

---

### LogMeal API

**Service:** LogMeal (external REST API, called via `http` package)  
**Philosophy:** LogMeal is a computer vision API specialized in food recognition. It analyzes a food photo and returns a list of identified ingredients with portion estimates. It is trained specifically on food images, giving it higher accuracy than general-purpose vision models for this task.

**Why here:** Primary visual food recognition path when no barcode is found. The image is uploaded to the LogMeal API, which returns food suggestions. These suggestions are then fuzzy-matched against the internal master food list (~1800 items) to find the closest matching entries. Requires a `LOGMEAL_API_TOKEN` in `env.json`.

---

### Claude Vision API (Anthropic)

**Service:** Claude API (Anthropic) — `claude-sonnet-4-20250514` model with vision (see `lib/data/api/foodscanner/claude_vision_provider.dart`)  
**Philosophy:** Claude is a large language model with multimodal capabilities — it can analyze images and respond in natural language. Unlike specialized food recognition APIs, it can describe what it sees in context and reason about ambiguous cases.

**Why here:** Backup recognition path when LogMeal fails or returns low-confidence results. The food photo is sent to Claude with a prompt asking for food identification. Requires a `CLAUDE_API_KEY` in `env.json`. This is one of the few places where NutRenaissance uses AI inference at runtime. **Note:** production builds currently ship without a `CLAUDE_API_KEY` (it is not provided by the Codemagic pipeline), so this path is inactive in prod and the scanner falls back to LogMeal — graceful degradation.

---

## 9. Networking

### http

**Package:** `http ^1.3.0`  
**Philosophy:** Dart's standard HTTP client library. Simple, low-level: `http.get()`, `http.post()`, etc. Returns `Response` objects with status codes and body strings. No magic.

**Why here:** All REST API calls to the AWS API Gateway use this package. The `ApiHelper` base class wraps it to add auth token injection, token refresh logic, and error normalization into `HttpException`.

---

### chuck_interceptor

**Package:** `chuck_interceptor ^2.2.6`  
**Philosophy:** A network request inspector for Flutter. Captures all HTTP requests and responses and displays them in a built-in overlay UI (accessed by shaking the device in debug mode). Similar to Charles Proxy but built into the app itself.

**Why here:** Development and debugging tool only. Used in `debug` builds to inspect what API calls the app is making, what it's sending, and what it's receiving — without needing an external proxy. Not active in production builds.

---

## 10. UI Libraries

### flutter_svg

**Package:** `flutter_svg ^2.0.9`  
**Philosophy:** Renders SVG (Scalable Vector Graphics) files natively in Flutter. Flutter does not support SVG out of the box — this package parses SVG files and draws them on Flutter's canvas.

**Why here:** The `assets/svg/` folder contains all UI icons as SVG. SVGs scale perfectly to any screen density without pixelation, unlike raster images. Essential for a modern mobile UI that targets both low and high-density screens.

---

### flutter_html

**Package:** `flutter_html ^3.0.0-beta.2`  
**Philosophy:** Renders HTML content as Flutter widgets. Parses a subset of HTML/CSS and translates it into a Flutter widget tree. Useful for displaying content that comes from a CMS or is authored as HTML (formatted text, links, lists, etc.).

**Why here:** Used to render the privacy policy, terms of service, and nutrition recommendation content stored in `assets/html/`. **Note:** This package is at a beta version (`3.0.0-beta.2`) — a risk in production screens.

---

### table_calendar

**Package:** `table_calendar ^3.0.8`  
**Philosophy:** A highly customizable calendar widget for Flutter. Supports week/month views, event markers, date range selection, and locale-aware formatting.

**Why here:** The date selector on the Dashboard that lets users navigate between days and weeks.

---

### flutter_typeahead

**Package:** `flutter_typeahead ^5.2.0`  
**Philosophy:** An autocomplete/typeahead widget. As the user types, it shows a dropdown of suggestions fetched from any data source (local list, API, etc.).

**Why here:** The food and sport search fields. As the user types "arroz" or "swimming", suggestions appear from the local master food/sport lists (~1800 foods, ~800 sports).

---

### Other UI utilities

| Package | Purpose |
|---------|---------|
| `flutter_spinkit ^5.1.0` | Animated loading spinners (consistent loading states across screens) |
| `percent_indicator ^4.2.2` | Circular and linear progress bars (nutrient progress towards RDA) |
| `carousel_slider ^5.1.2` | Horizontal swipeable card carousel (onboarding, recommendations) |
| `numberpicker ^2.1.1` | Scroll-wheel number picker (food quantities, water intake) |
| `fluttertoast ^9.0.0` | Brief non-blocking notification toasts (action confirmations) |
| `url_launcher ^6.2.4` | Opens URLs in the device browser (external links in recommendations) |
| `upgrader ^12.5.0` | Prompts the user to update when a newer app version is available on the store |
| `cupertino_icons ^1.0.2` | Apple-style SF Symbols icons for iOS-consistent UI elements |
| `flutter_launcher_icons ^0.14.4` | Generates app icon assets for all required Android/iOS sizes from a single source image |

---

## 11. Internationalization

### Flutter l10n (intl + flutter_localizations)

**Packages:** `intl ^0.20.0` + `flutter_localizations` (Flutter SDK)  
**Philosophy:** Flutter's official localization system. Translation strings are stored in `.arb` (Application Resource Bundle) files — one per language. The `flutter gen-l10n` tool generates a type-safe Dart class (`AppLocalizations`) with one getter per string. At runtime, Flutter selects the right locale based on the device language.

```
lib/infrastructure/l10n/
├── app_en.arb     # English strings
├── app_es.arb     # Spanish strings
└── generated/
    └── app_localizations.dart   # Generated — never edit manually
```

**Why here:** NutRenaissance supports Spanish and English. All user-facing strings go through `AppLocalizations`, including error messages (in `ErrorResolver`). The `untranslated-messages.txt` file at the root tracks strings missing in one language.

---

## 12. Code Generation

These tools generate Dart code automatically from annotations, avoiding repetitive boilerplate.

### build_runner

**Package:** `build_runner ^2.0.0`  
**Philosophy:** A Dart build system that watches for annotated source files and runs code generators against them. It is the engine — the other tools below are generators that plug into it.

**Run with:** `flutter pub run build_runner build` (one-time) or `flutter pub run build_runner watch` (continuous).

---

### json_serializable / json_annotation

**Packages:** `json_serializable ^6.7.0` + `json_annotation ^4.8.1`  
**Philosophy:** Generates `fromJson()` and `toJson()` methods for Dart model classes. You annotate a class with `@JsonSerializable()` and build_runner generates the serialization code. Avoids manually writing JSON parsing for every model — error-prone and verbose.

**Why here:** Used for API request/response DTOs — the classes that represent the JSON bodies sent to and received from the AWS API Gateway.

---

### drift_dev

**Package:** `drift_dev ^2.14.0`  
**Philosophy:** The code generator for Drift. You define your database schema in Dart (tables, columns, types), and drift_dev generates the full DAOs (Data Access Objects), query methods, and result classes. The generated code is type-safe — a wrong column name is a compile error, not a runtime crash.

**Why here:** Generates all the query code for the 6-table `ReferenceDatabase` (NutrientCompositions, SportMets, etc.).

---

## 13. Testing

### flutter_test (Flutter SDK)

The built-in Flutter testing framework. Provides `testWidgets()` for UI tests (renders widgets in a simulated environment), `test()` for pure Dart unit tests, and `expect()` / `matcher` assertions. No external dependency.

---

### mockito + mocktail

**Packages:** `mockito ^5.4.0` + `mocktail ^1.0.0`  
**Philosophy:** Mock object libraries for Dart. They let you create fake implementations of interfaces or abstract classes for testing. You define what a mock returns when called, then verify it was called with the right arguments. Mockito uses code generation (via build_runner); Mocktail uses runtime reflection (no generation needed).

**Why here:** Tests inject mock repositories and APIs into interactors and BLoCs, so each unit is tested in isolation without hitting real databases or network. See `test/mocks/`.

---

### bloc_test

**Package:** `bloc_test ^10.0.0`  
**Philosophy:** A testing utility specifically for flutter_bloc. Provides `blocTest()` — a declarative way to test BLoC state transitions: "given this initial state, when this event is added, expect these states to be emitted." Much cleaner than manually subscribing to streams.

**Why here:** The 50+ BLoCs are tested with `blocTest()` in `test/bloc/`.

---

### flutter_lints

**Package:** `flutter_lints ^6.0.0`  
**Philosophy:** A curated set of Dart/Flutter linting rules maintained by the Flutter team. `flutter analyze` runs these rules and reports violations. Enforces code style, catches common mistakes (like unnecessary imports or unused variables), and promotes idiomatic Dart patterns.

**Why here:** Active in both local development and CI (Bitbucket Pipelines runs `flutter analyze` on every push).

---

## 14. CI/CD & Developer Tools

### Codemagic

**Service:** Codemagic (cloud CI/CD for mobile apps)  
**Philosophy:** A CI/CD platform specialized for mobile apps (Flutter, React Native, iOS, Android). It understands Flutter's build system natively and manages the complexity of mobile code signing — fetching certificates, managing provisioning profiles, and encoding keystores as environment variables.

**Why here:** Three workflows live in `codemagic.yaml`: `pr-checks` (analyze + test on every pull request), `android-release` (builds a signed AAB to the Google Play internal track), and `ios-release` (builds a signed IPA and submits to TestFlight). The two release workflows are configured to trigger on push to `master`; in current operation builds are launched manually from the Codemagic UI under Ion's personal account.

Signing credentials stored in Codemagic (not in the repo):
- `android_signing` group: `CM_KEYSTORE`, `CM_KEYSTORE_PASSWORD`, `CM_KEY_PASSWORD`, `CM_KEY_ALIAS`
- `ios_group` group: `APP_STORE_CONNECT_KEY_IDENTIFIER`, `APP_STORE_CONNECT_ISSUER_ID`, `APP_STORE_CONNECT_PRIVATE_KEY`

---

### Bitbucket Pipelines

**Service:** Bitbucket Pipelines (Atlassian)  
**Philosophy:** CI/CD built into Bitbucket. Defined in `bitbucket-pipelines.yml`. Runs validation steps on every push — not builds. Faster and cheaper than Codemagic for simple checks.

**Why here:** Runs `flutter analyze` + `flutter test` + coverage on every commit. Acts as a quality gate before code reaches `master`. Codemagic takes over for the actual release build.

---

### FVM (Flutter Version Manager)

**Tool:** FVM (community tool, not a package)  
**Philosophy:** FVM manages multiple Flutter SDK versions on the same machine — similar to `nvm` for Node.js or `pyenv` for Python. The `.fvmrc` file at the project root pins the required Flutter version. `fvm flutter` runs the pinned version instead of the globally installed one.

**Why here:** Pins the project to Flutter `3.32.8`. Without FVM, a developer with a newer Flutter version globally installed might get different behaviour or breaking changes. Codemagic also reads `.fvmrc` to use the correct version in CI.

---

### sprintf

**Package:** `sprintf ^7.0.0`  
**Philosophy:** A Dart port of the C/Python `sprintf` function. Formats strings with positional placeholders (`%s`, `%d`, `%.1f`). 

**Why here:** Used for formatting localized strings that need variable substitution — for example, "You have consumed %s kcal today" — in combination with the l10n system.

---

### flutter_timezone

**Package:** `flutter_timezone ^5.0.1`  
**Philosophy:** Retrieves the device's current IANA timezone string (e.g., `"Europe/Madrid"`) using native platform APIs.

**Why here:** Routine scheduling requires the user's timezone to create the correct EventBridge cron expression. Without this, a user in Madrid would get their 08:00 breakfast routine at 08:00 UTC (09:00 or 10:00 local time depending on DST).

---

### path_provider + path

**Packages:** `path_provider ^2.1.0` + `path ^1.8.0`  
**Philosophy:** `path_provider` returns platform-appropriate filesystem paths (documents directory, cache directory, temp directory) without hardcoding platform-specific strings. `path` provides utilities for joining and manipulating file paths in a cross-platform way.

**Why here:** Used by Drift to locate and open the SQLite database file in the correct platform directory, and by Hive to store its box files.

---

*Document generated June 2026. Package versions from `pubspec.yaml` at Flutter 3.32.8 / Dart >=3.8.0.*
