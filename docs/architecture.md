# NutRenaissance - System Architecture

> A comprehensive nutrition and health tracking app built with Flutter (client) and AWS serverless (backend).

---

## Table of Contents

1. [High-Level Overview](#1-high-level-overview)
2. [Technology Stack](#2-technology-stack)
3. [Clean Architecture Layers](#3-clean-architecture-layers)
4. [AWS Backend](#4-aws-backend)
5. [Authentication](#5-authentication)
6. [Data Layer](#6-data-layer)
7. [Local Storage](#7-local-storage)
8. [Sync System](#8-sync-system)
9. [Infrastructure Services](#9-infrastructure-services)
10. [Presentation Layer](#10-presentation-layer)
11. [UX Flow Map](#11-ux-flow-map)
12. [Event Types & Models](#12-event-types--models)
13. [Master Data System](#13-master-data-system)
14. [Client-Side Computation](#14-client-side-computation)
15. [Food Scanner Pipeline](#15-food-scanner-pipeline)
16. [Routine Scheduling](#16-routine-scheduling)
17. [Environment Configuration](#17-environment-configuration)
18. [Dead Code & Deprecated Systems](#18-dead-code--deprecated-systems)

---

## 1. High-Level Overview

```
+---------------------+        HTTPS (API Gateway)        +------------------------+
|                     | ---------------------------------> |                        |
|   Flutter App       |                                    |   AWS Backend          |
|   (Android / iOS)   | <--------------------------------- |   (eu-west-3)          |
|                     |        JSON responses              |                        |
+---------------------+        FCM push notifications      +------------------------+
        |                                                          |
        |  Local Storage                                           |  AWS Services
        |  - Hive (30+ boxes)                                      |  - API Gateway
        |  - Drift SQL (6 tables)                                  |  - Lambda (40+)
        |  - SharedPreferences                                     |  - DynamoDB (9+ tables)
        |                                                          |  - S3 (master files)
        |  Client-Side Computation                                 |  - EventBridge Scheduler
        |  - Nutrient calculation                                  |  - Cognito (auth)
        |  - Sport kcal calculation                                |  - FCM via Firebase Admin
        |  - Profile/RDA computation                               |  - Secrets Manager
        |  - Food recommendations                                  |
        |                                                          |
        |  Device Integration                                      |
        |  - Health Connect (Android)                              |
        |  - HealthKit (iOS)                                       |
        |  - Camera (ML Kit barcode)                               |
        |  - Firebase (Crashlytics, FCM)                           |
```

### Design Principles

- **Offline-first**: All writes save to Hive immediately; API calls are async with queue fallback
- **Client-side computation**: Nutrient, kcal, RDA, and recommendation calculations run locally (ported from Lambdas)
- **Incremental sync**: Master files versioned; events synced by ID filtering to minimize payload
- **Reactive UI**: DashboardEventBus broadcasts data changes across BLoCs without tight coupling

---

## 2. Technology Stack

| Layer | Technology |
|-------|-----------|
| **UI Framework** | Flutter 3.13.8 (Dart) |
| **State Management** | flutter_bloc (BLoC pattern) |
| **Local DB (KV)** | Hive (30+ boxes, TypeAdapters) |
| **Local DB (SQL)** | Drift (6 tables, generated DAOs) |
| **Preferences** | SharedPreferences |
| **Auth** | AWS Cognito via Amplify Flutter SDK |
| **Push Notifications** | Firebase Cloud Messaging (FCM) |
| **Crash Reporting** | Firebase Crashlytics |
| **Health Data** | health package (Health Connect / HealthKit) |
| **Barcode Scanning** | Google ML Kit |
| **Visual Food Recognition** | LogMeal API, Claude Vision API |
| **HTTP Debugging** | Chuck interceptor (debug builds only) |
| **Localization** | Flutter l10n (EN, ES) |
| **Backend** | AWS Lambda (Node.js 20.x), API Gateway, DynamoDB, S3, EventBridge |

---

## 3. Clean Architecture Layers

```
┌─────────────────────────────────────────────────────────┐
│  PRESENTATION                                           │
│  ┌─────────────┐  ┌──────────┐  ┌───────────────────┐  │
│  │  Screens     │  │  BLoCs   │  │  Shared Widgets   │  │
│  │  (72 routes) │  │  (50+)   │  │  (80+ components) │  │
│  └──────┬───────┘  └────┬─────┘  └───────────────────┘  │
│         │               │                                │
├─────────┼───────────────┼────────────────────────────────┤
│  DOMAIN │               │                                │
│         │         ┌─────┴──────┐                         │
│         │         │ Interactors│  (150+ use cases)       │
│         │         │ (abstract) │                         │
│         │         └─────┬──────┘                         │
│         │               │                                │
├─────────┼───────────────┼────────────────────────────────┤
│  DATA   │               │                                │
│  ┌──────┴───────┐ ┌─────┴──────┐ ┌───────────────────┐  │
│  │ Repositories  │ │  API Layer │ │  Local Storage    │  │
│  │ (Impl)        │ │  (20+ APIs)│ │  (Hive + Drift)   │  │
│  └──────┬────────┘ └─────┬──────┘ └───────────────────┘  │
│         │                │                                │
├─────────┼────────────────┼────────────────────────────────┤
│  INFRASTRUCTURE                                          │
│  ┌──────────────┐ ┌─────────────┐ ┌──────────────────┐   │
│  │ Auth Service  │ │ Computation │ │ Services         │   │
│  │ (Cognito)     │ │ Services    │ │ (FCM, Midnight,  │   │
│  │              │ │ (Nutrient,  │ │  SyncQueue,      │   │
│  │              │ │  Sport,     │ │  EventBus,       │   │
│  │              │ │  Profile,   │ │  HealthSync)     │   │
│  │              │ │  Recommend) │ │                  │   │
│  └──────────────┘ └─────────────┘ └──────────────────┘   │
└──────────────────────────────────────────────────────────┘
```

### Key Files

| Layer | Path | Contents |
|-------|------|----------|
| Presentation | `lib/presentation/*/view/` | Screen widgets (72 routes) |
| Presentation | `lib/presentation/*/bloc/` | BLoC classes (50+) |
| Presentation | `lib/presentation/widgets/` | Shared UI components (80+) |
| Domain | `lib/domain/interactor/` | Use case interfaces + implementations (150+) |
| Data | `lib/data/repository/` | Repository implementations |
| Data | `lib/data/api/` | HTTP API classes (20+) |
| Data | `lib/data/local/` | Hive entities, Drift database |
| Infrastructure | `lib/infrastructure/` | Auth, services, HTTP, errors, l10n |
| Bootstrap | `lib/app_bootstrap.dart` | DI wiring, route map (~1600 lines) |

---

## 4. AWS Backend

### 4.1 Architecture Overview

```
                          ┌──────────────┐
                          │   Cognito     │
                          │  User Pool    │
                          └──────┬───────┘
                                 │ ID Token
                                 ▼
┌─────────┐    HTTPS     ┌──────────────┐     ┌──────────────────┐
│  App    │ -----------> │ API Gateway  │ --> │  Lambda Functions │
│         │ <----------- │  (REST)      │ <-- │  (Node.js 20.x)  │
└─────────┘   JSON       └──────────────┘     └────────┬─────────┘
                                                       │
                          ┌────────────────────────────┼──────────────┐
                          │                            │              │
                    ┌─────┴──────┐  ┌─────────┐  ┌────┴─────┐  ┌────┴──────┐
                    │  DynamoDB   │  │   S3    │  │EventBridge│  │  Secrets  │
                    │  (9+ tables)│  │(master  │  │ Scheduler │  │  Manager  │
                    │             │  │ files)  │  │(routines) │  │ (FCM key) │
                    └─────────────┘  └─────────┘  └──────┬────┘  └───────────┘
                                                         │
                                                    ┌────┴─────┐
                                                    │  Lambda   │
                                                    │ (routine  │
                                                    │  handler) │
                                                    └────┬──────┘
                                                         │ FCM push
                                                         ▼
                                                    ┌──────────┐
                                                    │ Firebase  │
                                                    │   FCM     │
                                                    └──────────┘
```

### 4.2 API Gateway

| Environment | Base URL | API ID |
|-------------|----------|--------|
| **Prod** | `https://05kpv2341k.execute-api.eu-west-3.amazonaws.com/prod` | `05kpv2341k` |
| **Dev** | `https://8bymr2h348.execute-api.eu-west-3.amazonaws.com/dev` | `8bymr2h348` |

### 4.3 API Endpoints

**Event CRUD:**

| Method | Path | Lambda | Description |
|--------|------|--------|-------------|
| POST | `/food-event` | save-food-event-prod | Save pre-computed food event |
| DELETE | `/food-event` | save-food-event-prod | Delete food event |
| POST | `/sport-event` | save-sport-event-prod | Save pre-computed sport event |
| DELETE | `/sport-event` | save-sport-event-prod | Delete sport event |
| POST | `/liquid-event` | save-liquid-event-prod | Save pre-computed liquid event |
| DELETE | `/liquid-event` | save-liquid-event-prod | Delete liquid event |
| POST | `/water-event` | — | Save water event |
| POST | `/creatine` | — | Save creatine supplement event |
| POST | `/collagen` | — | Save collagen supplement event |
| POST | `/supplements` | — | Save/delete supplement event |
| DELETE | `/supplements` | — | Delete supplement event |
| POST | `/feces` | — | Save feces event |
| DELETE | `/feces` | — | Delete feces event |
| POST | `/urine` | — | Save urine event |
| DELETE | `/urine` | — | Delete urine event |
| POST | `/sleep-event` | — | Save sleep event |
| POST | `/steps-count` | — | Save step count |

**Routines (EventBridge-backed):**

| Method | Path | Lambda | Description |
|--------|------|--------|-------------|
| POST | `/food-routines` | food-routines-prod | Create food routine + EventBridge schedules |
| DELETE | `/food-routines` | food-routines-prod | Delete food routine + EventBridge schedules |
| POST | `/sport-routine/v2` | add-sports-routine-prod | Create sport routine + EventBridge schedules |
| DELETE | `/sport-routine/v2` | add-sports-routine-prod | Delete sport routine + EventBridge schedules |
| POST | `/supplement-routines` | ScheduleSupplementRoutine | Create supplement routine + EventBridge schedules |
| DELETE | `/supplement-routines` | ScheduleSupplementRoutine | Delete supplement routine + EventBridge schedules |

**Favorites:**

| Method | Path | Description |
|--------|------|-------------|
| POST/DELETE | `/favorites/food` | Food favorites |
| POST/DELETE | `/favorites/sport` | Sport favorites |
| POST/DELETE | `/favorites/liquid` | Liquid favorites |
| POST/DELETE | `/favorites/supplement` | Supplement favorites |
| POST/DELETE | `/favorites/recipe` | Recipe favorites |

**User & Profile:**

| Method | Path | Description |
|--------|------|-------------|
| POST | `/profile` | Save user profile |
| GET | `/users?email={email}` | Download profile by email |
| POST | `/users` | Create/register user |
| POST | `/fcm-token` | Register FCM token |
| DELETE | `/fcm-token` | Unregister FCM token |

**Sync & Master Data:**

| Method | Path | Description |
|--------|------|-------------|
| POST | `/events-sync-test` | Bidirectional event sync (20 categories) |
| GET | `/manage-master-files?...` | Versioned master file check (15 file types) |
| GET | `/recommendations?userId=` | Get nutrition recommendations |
| GET | `/recipes?foodIds=` | Get recipes by food IDs |

### 4.4 DynamoDB Tables

| Table Name | Partition Key | Sort Key | Description |
|-----------|---------------|----------|-------------|
| `foodEventsProd` | userId (S) | eventId (N) | Food consumption events |
| `foodRoutinesProd` | userId (S) | eventId (N) | Recurring food routines |
| `sportEventsProd` | userId (S) | eventId (N) | Sport/exercise events |
| `sportRoutinesProd` | userId (S) | eventId (N) | Recurring sport routines |
| `liquidEventsProd` | userId (S) | eventDate (N) | Liquid consumption events |
| `supplementEventsProd` | userId (S) | eventId (N) | Supplement intake events |
| `supplementRoutinesProd` | userId (S) | eventId (N) | Recurring supplement routines |
| `profilesProd` | userId (S) | — | User profiles & health data |
| `fcm-tokens` | token (S) | — | FCM tokens (GSI: userId-index) |

### 4.5 S3 Buckets

| Bucket | Contents |
|--------|----------|
| `nutrients-pro` | `nutrients.json` (~1800 foods), `sports.json`, `objective-nutrients.json`, `nutrient-objective.json`, `nutrients_loss_table.json` |
| `master-files-app-pro` | `master-info-files.json` (cooking methods, oils, units, conversion factors, food groups) |

### 4.6 Lambda Categories

**Active — Simple Persistence:**
Lambdas that write pre-computed data to DynamoDB (all computation done client-side):
- `save-food-event-prod`, `save-sport-event-prod`, `save-liquid-event-prod`, `save-profile-data-prod`

**Active — Routine Scheduling:**
Lambdas that write to DynamoDB AND create EventBridge Scheduler schedules:
- `ScheduleSupplementRoutine`, `food-routines-prod`, `add-sports-routine-prod`
- On save: upsert DynamoDB + create cron schedules per day-of-week
- On delete: remove DynamoDB entry + delete EventBridge schedules
- Schedule naming: `routine-{userIdPrefix}-{eventId}-{dayName}`

**Active — Scheduled Handlers:**
Lambdas invoked by EventBridge at scheduled times:
- `food-routines-prod-action-handler`, `sport-routine-scheduled-handler-prod`, supplement routine handler
- These create the actual events in DynamoDB for the current day and send FCM push notifications

**Active — Sync & Notifications:**
- `events-sync-prod` — Bidirectional event sync across 20 categories
- `send-fcm-notification` — Sends data-only FCM pushes (reads tokens from `fcm-tokens` table)

**Deprecated — Computation Lambdas (moved client-side):**
- `food-event-amplify-prod` — Was: fetch S3 + compute nutrients. Now: client computes, save-food-event-prod just writes
- `sport-event-amplify-prod` — Was: fetch weight + S3 + compute kcal. Now: client computes
- `liquid-event-amplify-prod` — Was: fetch S3 + compute nutrients. Now: client computes
- `upload-profile-data-prod` (old) — Was: compute BMR/RDA/micronutrients. Now: ProfileComputationService

### 4.7 Region & Account

| Field | Value |
|-------|-------|
| Region | `eu-west-3` (Paris) |
| Account ID | `146380687031` |

---

## 5. Authentication

### Flow

```
App Launch
    │
    ▼
LateAuthenticationService.instance (no network, instant)
    │
    ├── runApp() immediately
    │
    ▼
SplashScreen
    │
    ├── fire-and-forget: CognitoAuthenticationService.initialize()
    │       │
    │       └── Amplify.configure() → Cognito User Pool
    │
    ├── check userId in local prefs (no network)
    │       │
    │       ├── userId exists → Dashboard (returning user)
    │       │
    │       └── no userId → Login screen
    │
    ▼
Login Screen
    ├── SignIn: Cognito USER_SRP_AUTH → ID Token → store in prefs
    ├── SignUp: Cognito createUser → email verification → sign in
    └── Forgot Password: Cognito resetPassword → confirmResetPassword
```

### Token Management

- **ID Token** stored in SharedPreferences via `PreferencesRepository`
- **Expiry check** before every API call (JWT decode → exp field)
- **Auto-refresh** via `CognitoAuthenticationService.fetchUserAttributes(forceRefresh: true)`
- **Injected** into all requests as `Authorization` header

### LateAuthenticationService Pattern

The `LateAuthenticationService` wraps `CognitoAuthenticationService` to solve the white-screen-on-launch problem:
- Created instantly in `main()` (no network call)
- Passed to all ~30 API objects via constructor
- Has `initialize()` called from splash screen (fire-and-forget)
- All auth methods wait for initialization via a `Completer` (15s safety timeout)
- API calls made before init completes just wait — they don't crash

### Cognito Configuration

| Environment | Pool ID | Client ID |
|-------------|---------|-----------|
| Prod | `eu-west-3_sZA2GWT5W` | `d1lt020mqpfmkq1vkkm0dsgpd` |
| Dev | `eu-west-3_ewIR3R9Sl` | `729e89vrtssaguuv0hpdkhs1eg` |

---

## 6. Data Layer

### 6.1 Repository Pattern

Every domain concern has a repository interface (in `lib/domain/`) and implementation (in `lib/data/repository/`). Repositories orchestrate local storage, API calls, computation services, and the sync queue.

```
Repository (orchestrator)
    ├── LocalStorageRepository (Hive read/write)
    ├── API class (HTTP calls)
    ├── ComputationService (local enrichment)
    └── SyncQueueService (offline queue fallback)
```

### 6.2 Key Repositories

| Repository | Manages | Key Operations |
|-----------|---------|----------------|
| `FoodEventsRepositoryImpl` | Food events | Save (with nutrient enrichment), upload, get today/week events |
| `SportEventsRepositoryImpl` | Sport events | Save (with kcal calculation), upload, get today/week events |
| `LiquidEventsRepositoryImpl` | Liquid events | Save (with nutrient enrichment), upload, get today events |
| `WaterEventRepositoryImpl` | Water events | Fire-and-forget save with sync queue fallback |
| `SupplementsRepositoryImpl` | Supplement events, favorites, routines | Separate boxes for events/favorites/routines |
| `FoodRoutinesRepositoryImpl` | Food routines | CRUD + EventBridge scheduling (via API) |
| `RoutinesRepositoryImpl` | Sport routines | CRUD + EventBridge scheduling (via API) |
| `FavoritesRepositoryImpl` | Food, sport, liquid favorites | CRUD with local + remote sync |
| `FecesUrineRepositoryImpl` | Feces and urine events | Separate endpoints (/feces, /urine) |
| `ProfileRepositoryImpl` | User profile | Save with local computation, sync queue fallback |
| `MasterFilesRepositoryImpl` | 15 master data types | Versioned fetch, Drift sync, food flag stamping |
| `EventsSynchronizationRepositoryImpl` | Cross-device sync | Collects local IDs → POST to sync API → merge incoming |
| `RecipesRepositoryImpl` | Recipes | Fetch by food IDs, manage recipe favorites |
| `HealthSyncRepositoryImpl` | Health metadata | Steps/sleep sync metadata |

### 6.3 API Layer

All APIs extend `ApiHelper` which provides:
- HTTP methods (POST, GET, DELETE, PUT)
- Auth token injection (`Authorization` header)
- Auto token refresh on expiry
- Chuck interceptor for debug HTTP logging
- `HttpException` on non-200 responses

```
lib/data/api/
├── foodevents/food_events_api.dart        POST/DELETE /food-event
├── sportevents/sport_events_api.dart      POST/DELETE /sport-event
├── liquidevents/liquid_events_api.dart    POST/DELETE /liquid-event
├── waterevents/water_events_api.dart      POST /water-event
├── supplements/supplemets_api.dart        POST/DELETE /supplements, /creatine, /collagen, /supplement-routines
├── fecesurine/fece_urine_api.dart         POST/DELETE /feces, /urine
├── favorites/favorites_api.dart           POST/DELETE /favorites/{food,sport,liquid}
├── foodroutines/food_routines_api.dart    POST/DELETE /food-routines
├── routines/routines_api.dart             POST/DELETE /sport-routine/v2
├── eventssync/events_sync_api.dart        POST /events-sync-test (20 categories)
├── masterfiles/master_files_api.dart      GET /manage-master-files (15 version params)
├── profile/profile_api.dart               POST /profile, GET /users
├── recipes/recipes_api.dart               GET /recipes, POST/DELETE /favorites/recipe
├── recommendations/recommendations_api.dart GET /recommendations
├── sleepevents/sleep_events_api.dart      POST /sleep-event
├── steps/steps_api.dart                   POST /steps-count
└── foodscanner/                           Barcode (OpenFoodFacts, LogMeal, Claude Vision)
```

### 6.4 Save Flow (Example: Food Event)

```
User taps Save
    │
    ▼
AddFoodEventBloc → SaveFoodEventInteractor
    │
    ▼
FoodEventsRepository.saveFoodEvent()
    │
    ├── 1. NutrientCalculationService.enrichFoodEvent()
    │       ├── Resolve unit → grams (from UnitFoods master data)
    │       ├── Apply conversion factor (raw → cooked weight)
    │       ├── Apply cooking oil absorption (from Drift CookingMethodOils)
    │       ├── Compute nutrients: weight × nutrientValue / 100
    │       └── Apply cooking losses (from Drift NutrientLosses)
    │
    ├── 2. LocalStorageRepository.saveFoodEvent(entity)  ← Hive write (instant)
    │
    ├── 3. FoodEventsApi.saveFoodEvent(enriched)          ← async HTTP POST
    │       │
    │       ├── Success → done
    │       └── Failure → SyncQueueService.enqueue('/food-event', body)
    │
    └── 4. DashboardEventBus.notify(DataChangedCategory.food)
            │
            └── DashboardBloc rebuilds food section on Dashboard
```

---

## 7. Local Storage

### 7.1 Hive (Key-Value, 30+ boxes)

Managed by `LocalStorageImpl`. Each entity type has a dedicated box with Hive TypeAdapters.

**Event Boxes:**

| Box Name | Entity Type | Key Field |
|----------|-------------|-----------|
| `food_events` | FoodEventEntity | eventId |
| `food_routines` | FoodRoutineEntity | eventId |
| `liquid_events` | LiquidEventEntity | eventDate |
| `sport_events` | SportEventEntity | eventId |
| `sport_routines` | SportRoutineEntity | eventId |
| `supplement_events` | SupplementEventsEntity | eventId |
| `supplement_favorites` | SupplementEventsEntity | eventId |
| `supplement_routines` | SupplementEventsEntity | eventId |
| `feces_events` | UploadFecesEventEntity | eventId |
| `urine_events` | UploadFecesEventEntity | eventId |
| `creatine_events` | UploadSupplementEventEntity | eventId |
| `collagen_events` | UploadSupplementEventEntity | eventId |
| `sleep_events` | SleepEventEntity | — |
| `steps_events` | StepsEntity | — |

**Favorite Boxes:**

| Box Name | Entity Type |
|----------|-------------|
| `food_favorites` | FoodFavoriteEntity |
| `sport_favorites` | SportFavoriteEntity |
| `liquid_favorites` | LiquidFavoriteEntity |
| `recipe_favorites` | RecipeFavoriteEntity |

**Master Data Boxes (15):**
Each stores a single entity with a `v` (version) field for incremental updates:
`cookingMethods`, `cookingMethodsInfo`, `oilTypes`, `conversionFactors`, `conversionFactorsInfo`, `foodsAndDrinksNames` (~1800 items), `nutrientsInfo`, `objectivesInfo`, `recommendationGroups`, `sportsInfo`, `unitsInfo`, `unitsFoods`, `supplementsInfo`, `subjectiveAnalysis`, `cookingMethodsOilsInfo`

**Other Boxes:**
`profile`, `models_appearance`, `explaining_cards`, `subjective_analysis_results`, `health_sync_metadata`, `sync_queue`

### 7.2 Drift SQL Database

`ReferenceDatabase` (schema version 3) stores data that benefits from SQL queries:

| Table | Rows | Purpose |
|-------|------|---------|
| `NutrientCompositions` | ~1800 | Per-food nutrient values (116+ params as JSON), food metadata, recommendation flags |
| `NutrientLosses` | ~20 | Cooking method nutrient retention factors |
| `CookingMethodOils` | ~15 | Oil absorption % per cooking method |
| `SportMets` | ~800 | METs values per sport per intensity level |
| `ReferenceDataVersions` | ~5 | Version tracking for incremental updates |
| `ReferenceDataBlobs` | ~3 | Large JSON blobs (objective-nutrients, nutrient-objective) |

### 7.3 SharedPreferences

Simple key-value pairs: user ID, auth tokens, token expiry time, master file versions, first-launch flags, preference toggles.

---

## 8. Sync System

### 8.1 SyncQueueService (Offline Queue)

**Purpose:** Persist failed API calls and retry with exponential backoff.

**File:** `lib/infrastructure/services/sync_queue_service.dart`

```
SyncQueueEntry (persisted in Hive):
  ├── path: '/food-event'
  ├── bodyJson: '{"userId":"...","eventId":...}'
  ├── method: 'POST' or 'DELETE'
  ├── createdAt: epoch millis
  ├── retryCount: 0..10
  └── nextRetryAt: epoch millis
```

**Retry Strategy:**

| Retry # | Delay | Cumulative |
|---------|-------|------------|
| 1 | 2s | 2s |
| 2 | 4s | 6s |
| 3 | 8s | 14s |
| 4 | 16s | 30s |
| 5 | 32s | ~1m |
| 6 | 64s | ~2m |
| 7 | 128s | ~4m |
| 8 | 256s | ~8m |
| 9 | 300s (cap) | ~13m |
| 10 | 300s (cap) | ~18m |

**Error Handling:**
- 4xx (except 429): Permanent error → drop entry, report to Crashlytics
- 429/5xx/network error: Schedule retry with backoff
- After 10 retries: Reset backoff counter, keep entry (prevents data loss)

**Trigger Points:**
- App launch
- App resume from background
- After successful API calls (piggyback)
- FCM sync trigger

### 8.2 EventsSyncApi (Bidirectional Sync)

**Endpoint:** `POST /events-sync-test`

**20 Sync Categories:**
`foodEvents`, `foodRoutines`, `sportEvents`, `sportRoutines`, `liquidEvents`, `waterEvents`, `foodFavorites`, `sportFavorites`, `liquidFavorites`, `subjectiveAnalysis`, `recipeFavorites`, `fecesEvents`, `urineEvents`, `creatineEvents`, `collagenEvents`, `supplementEvents`, `supplementFavorites`, `supplementRoutines`, `sleepEvents`, `stepEvents`

**Sync Flow:**

```
App (EventsSynchronizationRepository)
    │
    ├── 1. Collect local event IDs from all 20 Hive boxes
    │
    ├── 2. POST /events-sync-test
    │       Body: { userId, foodEvents: ["id1","id2"], sportEvents: [...], ... }
    │       (IDs tell backend "I already have these, skip them")
    │
    ├── 3. Backend returns only NEW/UPDATED events per category
    │
    ├── 4. For each received event:
    │       ├── Map from API DTO → local entity
    │       └── Save to appropriate Hive box
    │
    └── 5. Broadcast DashboardEventBus notifications per affected category
```

### 8.3 FCM-Triggered Sync

```
Backend (routine handler fires)
    │
    ├── Writes event to DynamoDB
    │
    └── Invokes send-fcm-notification Lambda
            │
            ├── Looks up FCM tokens by userId (DynamoDB fcm-tokens table)
            │
            └── Sends data-only push: { category: "food"|"sport"|"supplement" }
                    │
                    ▼
App (FcmService)
    │
    ├── Receives FCM data message
    │
    ├── Maps category → partial sync
    │       food → sync foodEvents only
    │       sport → sync sportEvents only
    │       supplement → sync supplementEvents only
    │       unknown → full sync all categories
    │
    ├── UpdateEventsInteractor (partial) or SynchronizeEventsInteractor (full)
    │
    └── DashboardEventBus.notify(category) → UI rebuilds
```

### 8.4 Sync Triggers Summary

| Trigger | Sync Type | When |
|---------|-----------|------|
| App launch (splash) | Full sync | Fire-and-forget during splash |
| FCM push notification | Partial (by category) | Routine fires, backend pushes |
| App resume from background | Full sync | `didChangeAppLifecycleState` |
| SyncQueue processQueue | Individual retries | After any trigger above |
| Manual refresh | Full sync | User pull-to-refresh (if implemented) |

---

## 9. Infrastructure Services

### 9.1 DashboardEventBus

**File:** `lib/infrastructure/services/dashboard_event_bus.dart`

Singleton with a broadcast `StreamController<DataChangedCategory>`.

```dart
enum DataChangedCategory { food, water, liquid, sport, supplement, fecesUrine, profile, steps }
```

**How it works:**
- After any data save/sync, the caller emits: `DashboardEventBus.instance.notify(category)`
- Multiple BLoCs subscribe to the stream and rebuild on relevant category changes
- Enables reactive UI updates without BLoC-to-BLoC coupling

**Subscribers:** DashboardBloc, MealTimeDetailsBloc, WeeklyDashboardDetailBloc, SupplementsDetailBloc, and others.

### 9.2 MidnightService

**File:** `lib/infrastructure/services/midnight_service.dart`

Singleton that detects when the local clock crosses midnight.

- Calculates duration to next midnight + 500ms buffer
- Emits `DateTime` on broadcast stream
- `checkNow()` called on app resume to catch backgrounded-past-midnight
- Injectable `clock` for testing
- **MidnightToastMixin**: Shows snackbar on detail screens ("It's a new day!")
- Dashboard auto-refreshes date; detail screens just notify

### 9.3 FCM Service

**File:** `lib/infrastructure/services/fcm_service.dart`

- Singleton managing Firebase Cloud Messaging
- On `init()`: requests notification permissions, gets/caches FCM token
- `configureSyncHandler()`: wires up sync interactors to incoming FCM messages
- Maps `data['category']` → partial sync → EventBus notification
- `onDataMessage`: broadcast stream of incoming `RemoteMessage`
- Token refresh callback for updating server-side registry

### 9.4 Health Sync

**Package:** `health` (Health Connect on Android, HealthKit on iOS)

- Syncs **steps** and **sleep** data from device health platform
- Periodic sync every ~5 minutes when app is in foreground
- Manual sync from Health Sync Settings screen
- Background sync via WorkManager (partially implemented — needs Hive re-init in isolate)
- Data appears on Dashboard in Steps and Sleep widgets

### 9.5 Error Handling

**File:** `lib/infrastructure/errors/error_resolver.dart`

- `ErrorTypes` enum: 85+ error types covering auth, profile, events, sync, validation
- `resolveError()`: maps ErrorType → localized user message via `AppLocalizations`
- `userError()`: extracts message from Cognito errors (handles `_TypeError` gracefully)
- `resolveFormError()`: validation error messages

---

## 10. Presentation Layer

### 10.1 BLoC Pattern

Every screen has a BLoC with:
- **Actions** (input events): `class SomeAction extends BlocActions`
- **State** (output): immutable object with `copyWith()` for updates
- **Handlers**: `on<ActionType>((event, emit) { ... })` in BLoC constructor

**Example — DashboardBloc:**
- 30+ action classes (InitializeState, RefreshCategoryAction, FinishWaterEventAction, etc.)
- State with 38+ fields (food events, nutrients, water, supplements, loading flags, etc.)
- Subscribes to DashboardEventBus for reactive updates

### 10.2 Dependency Injection

All dependencies are wired in `app_bootstrap.dart` (~1600 lines) using constructor injection:

```
Phase 1: Services & APIs (auth, HTTP clients, computation services)
    ↓
Phase 2: Repositories (inject APIs, local storage, services)
    ↓
Phase 3: Interactors (inject repositories)
    ↓
Phase 4: BLoCs (inject interactors)
    ↓
Phase 5: MultiBlocProvider wraps MaterialApp (50+ BlocProviders)
```

No service locator (GetIt) — all direct constructor injection.

### 10.3 Navigation

- 72 named routes defined in `app_bootstrap.dart` (lines 1380-1453)
- Initial route: `/` → SplashScreen
- Arguments passed via `Navigator.pushNamed(context, route, arguments: model)`
- Received via `ModalRoute.of(context)?.settings.arguments`
- Some screens (FoodScannerScreen) use direct `MaterialPageRoute` push

### 10.4 Data Flow: User Action → UI Update

```
1. User taps button
    → Screen widget callback
    
2. Screen dispatches action
    → bloc.add(SomeAction(data))
    
3. BLoC handler executes
    → Calls interactor.execute(params)
    
4. Interactor delegates to repository
    → repository.save(entity)
    
5. Repository orchestrates
    → Local save (Hive) + API call (async) + SyncQueue (fallback)
    
6. Repository/service notifies
    → DashboardEventBus.notify(category)
    
7. Listening BLoCs rebuild
    → emit(state.copyWith(updatedData))
    
8. UI rebuilds
    → BlocBuilder detects state change → widget tree updates
```

---

## 11. UX Flow Map

### 11.1 App Entry

```
Cold Launch
    │
    ▼
SplashScreen (local checks only, no network blocking)
    │
    ├── Returning user (userId in prefs) → Dashboard
    │
    └── New user / logged out → LoginScreen
                                    │
                                    ├── Sign In → Dashboard
                                    │
                                    └── Sign Up → WelcomeScreen
                                                    │
                                                    └── HealthSyncOnboarding → Registry
                                                                                 │
                                                    GeneralQuestions → HealthQuestions
                                                    → DietQuestions → PhysicalActivity
                                                    → Objectives → Dashboard
```

### 11.2 Dashboard Hub

```
Dashboard
├── Week Calendar (date selector)
├── Nutrition Progress (kcal + macros)
│   └── tap → MacroNutrientsDetail / MicroNutrientsDetail
├── Meal Cards (Breakfast / Lunch / Dinner / Snack)
│   ├── tap card → MealTimeDetails → tap item → ItemUpdate
│   └── tap + → AddFoodEvent (with FoodScanner access)
├── Supplements Card
│   ├── tap → SupplementsDetail → tap item → UpdateSupplement
│   └── tap + → SupplementsScreen
├── Creatine / Collagen toggles
├── Water Widget (+ / - buttons)
│   └── tap info → LiquidSummaryDetail
├── Activity Log
│   ├── tap area → SportItems → tap item → SportUpdate
│   └── tap + → AddSportEvent
├── Sleep Widget (if health sync enabled)
├── Steps Widget (if health sync enabled)
└── Feces/Urine Card → FecesUrineTabHolder
```

### 11.3 Bottom Navigation

```
Bottom Bar
├── Home button → Dashboard
├── + button → Quick Add Menu
│   ├── Breakfast / Lunch / Dinner / Snack → AddFoodEvent (with mealType)
│   ├── Supplements → SupplementsScreen
│   ├── Physical Activity → AddSportEvent
│   └── Feces/Urine → FecesUrineTabs
└── Hamburger menu
    ├── Routines → RoutinesTabHolder (Meal / Workouts / Supplements tabs)
    ├── Favorites → FavoritesTabHolder (Meal / Physical Activity / Supplements tabs)
    ├── Tips → RecommendationsTabHolder (Tips / Food List tabs)
    ├── Recipes → RecipesTabHolder (Discover / Favorites tabs)
    └── Profile → ProfileScreen → SettingsScreen
```

### 11.4 Key User Flows

**Log a food event:**
```
Dashboard → + (Breakfast) → AddFoodEvent → search food → set quantity → Save
    → nutrient enrichment (client) → Hive write → API POST → Dashboard refreshes
```

**Use food scanner:**
```
AddFoodEvent → camera icon → FoodScannerScreen → capture photo
    ├── Barcode detected → ML Kit → OpenFoodFacts lookup → results
    └── No barcode → LogMeal API / Claude Vision → food suggestions → results
        → "Edit" (pre-fill AddFoodEvent) or "Log" (save directly)
```

**Create a routine:**
```
Hamburger → Routines → Supplements tab → + → SupplementsScreen (routine mode)
    → select supplement → set time → select days of week → Save
    → API POST → Lambda creates EventBridge schedules per day
    → At scheduled time: EventBridge → Lambda → DynamoDB write + FCM push → App syncs
```

**Cross-device sync:**
```
Device A: save food event → Hive + API POST → DynamoDB
Device B: app launch → SplashScreen → EventsSyncApi.syncAllData()
    → POST local IDs to /events-sync-test → receive new events → save to Hive → Dashboard shows
```

---

## 12. Event Types & Models

### 12.1 All Event Categories (20)

| Category | Model | Key Fields | DynamoDB Key |
|----------|-------|------------|-------------|
| `foodEvents` | FoodEventEntity | mealType, foodInfo (nutrients), eventKcals | userId + eventId |
| `foodRoutines` | FoodRoutineEntity | daysOfWeek, scheduleTime, mealType, isRoutine | userId + eventId |
| `sportEvents` | SportEventEntity | sportName, info (duration, intensity, kcal), source | userId + eventId |
| `sportRoutines` | SportRoutineEntity | daysOfWeek, scheduleTime, isRoutine | userId + eventId |
| `liquidEvents` | LiquidEventEntity | liquidInfo (nutrients), eventKcals | userId + eventDate |
| `waterEvents` | WaterEventEntity | quantity | userId + eventDate |
| `foodFavorites` | FoodFavoriteEntity | mealType, foodInfo, name | userId + eventId |
| `sportFavorites` | SportFavoriteEntity | sportName, info | userId + eventId |
| `liquidFavorites` | LiquidFavoriteEntity | liquidInfo | userId + eventId |
| `recipeFavorites` | RecipeFavoriteEntity | recipeId, ingredients | userId + eventDate |
| `supplementEvents` | SupplementEventsEntity | info (id, amount, unit), name | userId + eventId |
| `supplementFavorites` | SupplementEventsEntity | info, name | userId + eventId |
| `supplementRoutines` | SupplementEventsEntity | daysOfWeek, scheduleTime, timeZone | userId + eventId |
| `creatineEvents` | UploadSupplementEventEntity | — | userId + eventId |
| `collagenEvents` | UploadSupplementEventEntity | — | userId + eventId |
| `fecesEvents` | UploadFecesEventEntity | fecesId (Bristol scale) | userId + eventId |
| `urineEvents` | UploadFecesEventEntity | urineId (color scale) | userId + eventId |
| `sleepEvents` | SleepEventEntity | duration, source | userId + eventId |
| `stepEvents` | StepsEntity | count, source | userId + eventId |
| `subjectiveAnalysis` | SubjectiveAnalysisResultEntity | results | userId + eventDate |

### 12.2 Food Event Model (Detailed)

The most complex model in the system:

```
FoodEventEntity
├── userId, eventDate, eventId, mealType (0-3)
├── foodName, comment, dish (boolean)
├── eventKcals (pre-computed total)
└── foodInfo: List<FoodInfo>
        ├── id, group, name_en, name_es, recommendable
        ├── freeSugar
        ├── eventInfo:
        │   ├── cookingMethod (id)
        │   ├── qty (grams or units)
        │   ├── unit (measurement unit id)
        │   ├── conversionFactor (raw→cooked id)
        │   ├── usedOil (oil type id)
        │   └── waste (% discarded)
        └── params: Params (116+ nutrient fields)
            ├── energyKcal, protein, totalLipids, carbohydrates
            ├── vitA, vitB1..B12, vitC, vitD, vitE, vitK
            ├── calcium, iron, zinc, magnesium, potassium, sodium
            ├── cholesterol, fiber, freeSugar
            ├── omega3, omega6, EPA, DHA
            └── ... (116+ total fields)
```

### 12.3 User Profile Model

```
UserProfileEntity
├── commonName, birthDate, sex (1=M, 2=F)
├── physicalCharacteristics:
│   ├── height, weight, unit (1=metric, 2=imperial)
│   ├── waistMeasurement, bodyFat
│   └── femaleCharacteristics (menstruation, cycle, lastStartDate)
├── medicalSituation:
│   ├── commonDiseases, otherDiseases
│   └── pharmaceuticalTreatment
├── dietType, foodAversions, intolerances, allergens, exclusions
├── occupationActivityFactor
├── objectives (list of objective IDs)
├── symptoms
├── kcal (computed: BMR × activityFactor)
├── micronutrients, userAll, temporaryMicronutrients, temporaryAll
└── userRdas (per-nutrient RDA + upper limit)
```

---

## 13. Master Data System

### 13.1 Overview

15 master file types are version-tracked and incrementally synced from the backend.

```
App startup / Dashboard load
    │
    ├── MasterFilesRepository.checkAndUpdate()
    │       │
    │       ├── Read local versions from Hive (v field on each entity)
    │       │
    │       ├── GET /manage-master-files?cookingMethods=V1&nutrientsInfo=V2&...
    │       │
    │       ├── Server returns only CHANGED files (empty if all up-to-date)
    │       │
    │       └── For each changed file:
    │           ├── Save to Hive box (with new version)
    │           └── If applicable: sync to Drift (cooking oils, nutrient losses)
    │
    └── ReferenceDataService.refreshIfNeeded()
            │
            ├── Check versions in Drift ReferenceDataVersions
            │
            ├── Fetch from S3 via API (nutrients.json, sports.json, etc.)
            │
            └── Upsert into Drift tables (NutrientCompositions, SportMets, etc.)
```

### 13.2 Master File Types

| Type | Box | Contents | Used By |
|------|-----|----------|---------|
| foodsAndDrinksNames | Hive | ~1800 foods/drinks with names (EN/ES), groups | Food search autocomplete |
| nutrientsInfo | Hive | Nutrient definitions and labels | UI display |
| sportsInfo | Hive | Sport names (EN/ES), categories | Sport search autocomplete |
| supplementsInfo | Hive | Supplement names and categories | Supplement search |
| cookingMethods | Hive | Cooking method names | Food event form |
| cookingMethodsInfo | Hive | Cooking method metadata | Cooking method selection |
| cookingMethodsOilsInfo | Hive + Drift | Oil absorption % per method | NutrientCalculationService |
| oilTypes | Hive | Oil taxonomy | Cooking method oil selection |
| conversionFactors | Hive | Raw→cooked weight factors | NutrientCalculationService |
| conversionFactorsInfo | Hive | Factor metadata | Unit conversion |
| unitsInfo | Hive | Measurement units | Quantity input |
| unitsFoods | Hive | Food-specific unit equivalences | Unit conversion per food |
| objectivesInfo | Hive | Health objective definitions | Profile objectives |
| recommendationGroups | Hive | Food grouping for recommendations | RecommendationComputationService |
| subjectiveAnalysis | Hive | Subjective health assessment scales | (backend-only, no UI) |

### 13.3 Drift Reference Data

Loaded separately from S3 via `ReferenceDataService`:

| Data | Drift Table | Source | Used By |
|------|-------------|--------|---------|
| nutrients.json | NutrientCompositions | S3 nutrients-pro | NutrientCalculationService, RecommendationComputationService |
| nutrients_loss_table.json | NutrientLosses | S3 nutrients-pro | NutrientCalculationService (cooking losses) |
| cooking_oils_info | CookingMethodOils | Hive → Drift sync | NutrientCalculationService (oil absorption) |
| sports.json | SportMets | S3 nutrients-pro | SportKcalCalculationService |
| objective-nutrients.json | ReferenceDataBlobs | S3 nutrients-pro | ProfileComputationService |
| nutrient-objective.json | ReferenceDataBlobs | S3 nutrients-pro | ProfileComputationService |

---

## 14. Client-Side Computation

Four major computation services ported from Lambda to Dart for offline capability and reduced latency:

### 14.1 NutrientCalculationService

**Replaces:** `food-event-amplify-prod` and `liquid-event-amplify-prod` Lambdas

**Food Event Enrichment (6 steps):**

1. **Resolve unit** → grams (lookup UnitFoods for food-specific unit weights)
2. **Apply conversion factor** (raw → cooked weight adjustment)
   - Special cases: 9 food IDs skip conversion; ID 1865 forces factor=3
3. **Apply cooking oil absorption** (from CookingMethodOils table)
   - Fried foods (methodId=5) get extra kcal: `weight × percentage × 9 kcal/g`
4. **Compute nutrients**: `foodWeight × nutrientValue / 100` (from NutrientCompositions)
5. **Apply cooking losses**: `nutrientQty × (1 - loss)` (from NutrientLosses, per cooking method)
6. **Map to Params**: 116+ nutrient fields populated

**Liquid Event Enrichment:** Simpler — `qty × nutrientValue / 100` (no conversion factors or cooking losses)

### 14.2 SportKcalCalculationService

**Replaces:** `sport-event-amplify-prod` Lambda

**Formula:** `METs[intensity] × 0.0175 × userWeight(kg) × minutes`

- METs looked up from Drift SportMets table (array per intensity level)
- User weight fetched from local profile

### 14.3 ProfileComputationService

**Replaces:** `upload-profile-data-prod` Lambda

**Pipeline:**
1. Unit conversion (imperial → metric if needed)
2. Age calculation from birthDate
3. BMR calculation (Harris-Benedict for normal BMI, Mifflin-St Jeor for obese)
4. Kcal goal: `BMR × occupationActivityFactor`
5. RDA computation per nutrient (based on sex + age bracket)
6. Micronutrient prioritization:
   - Top-3 nutrients per objective, sorted by RDA priority
   - Borrowing pool for unused nutrients across objectives
   - Separate normal vs. temporary objective lists
   - Exclusions: choline, vitF never included

**Fallback:** Returns `null` if reference data (objective-nutrients, nutrient-objective) not yet loaded → caller uses Lambda instead.

### 14.4 RecommendationComputationService

**Replaces:** `food-recommendation-prod` Lambda

**9-step pipeline:**
1. Load NutrientCompositions from Drift (~1800 foods)
2. Identify repeated foods (3+ times in last 7 days)
3. Sum weekly nutrients from all food events
4. Calculate daily average (weekly / 7)
5. Find nutrient deficits (< 85% of RDA)
6. Get target nutrients from user objectives
7. Filter foods by exclusions, intolerances, diseases, symptoms, gut preference, rarity
8. Rank foods by nutrient coverage score (per objective + per deficit)
9. Per-group filtering with NOVA score classification

**NOVA Score:** Classifies foods 1-4 based on saturated fat, energy, sugar, sodium (different thresholds for foods vs. drinks).

---

## 15. Food Scanner Pipeline

```
AddFoodEventScreen → tap camera icon
    │
    ▼
FoodScannerScreen (camera preview)
    │
    ├── User captures photo
    │
    ├── ML Kit Barcode Detection (runs on captured image)
    │   │
    │   ├── Barcode found:
    │   │   └── OpenFoodFacts API lookup by barcode
    │   │       ├── Found → NutrientMapperService maps OFF fields → internal Params
    │   │       └── Not found → show "not found" message
    │   │
    │   └── No barcode:
    │       └── Visual Recognition:
    │           ├── LogMeal API (ingredient breakdown)
    │           └── Claude Vision API (food identification)
    │               │
    │               └── FuzzyMatcher: match results against master food list
    │                   ├── Match found → map to internal food ID
    │                   └── No match → negative ID (unmatched food)
    │
    ├── Results displayed:
    │   ├── "Edit" → return to AddFoodEvent pre-filled
    │   └── "Log" → save directly as food event
    │
    └── Offline check: _checkConnectivity() → show offline indicator
```

**NutrientMapperService** handles mapping between external data formats:
- OpenFoodFacts: `energy-kcal_100g` → `energyKcal`, salt → sodium conversion
- Passio: `calories` → `energyKcal`
- Duplicates fat subtypes into aggregate fields

---

## 16. Routine Scheduling

### 16.1 How Routines Work

```
User creates routine (app)
    │
    ├── Select items (food/sport/supplement)
    ├── Set time (HH:MM)
    ├── Select days of week (Mon-Sun)
    ├── Set timezone
    │
    ▼
API POST /supplement-routines (or /food-routines, /sport-routine/v2)
    │
    ▼
Lambda (e.g., ScheduleSupplementRoutine)
    │
    ├── 1. Upsert routine to DynamoDB
    │
    ├── 2. Delete old EventBridge schedules for this routine
    │       (by schedule name prefix: routine-{userId}-{eventId}-*)
    │
    └── 3. Create new EventBridge Scheduler schedules
            ├── One schedule per day of week
            ├── Name: routine-{userIdPrefix}-{eventId}-{dayName}
            ├── Cron: cron(minute hour ? * DAY *)
            ├── Timezone: user's timezone
            ├── Target: routine handler Lambda
            └── Flexible time window: OFF (exact)
```

### 16.2 When a Schedule Fires

```
EventBridge triggers at scheduled time
    │
    ▼
Routine Handler Lambda (e.g., food-routines-prod-action-handler)
    │
    ├── 1. Read routine config from event payload
    │
    ├── 2. Create actual event in DynamoDB (food/sport/supplement for today)
    │
    └── 3. Send FCM notification via send-fcm-notification Lambda
            │
            ├── Lookup FCM tokens by userId
            │
            └── Send data-only push: { category: "food"|"sport"|"supplement" }
                    │
                    ▼
App receives FCM → partial sync → Dashboard refreshes
```

### 16.3 Schedule Groups

| Group | Target Handler |
|-------|---------------|
| `food-routine-prod` | `food-routines-prod-action-handler` |
| `sport-routine-prod` | `sport-routine-scheduled-handler-prod` |
| `supplement-routine-prod` | Supplement routine handler |

---

## 17. Environment Configuration

**File:** `lib/infrastructure/environment/environment.dart`

| Setting | Dev | Prod |
|---------|-----|------|
| Base URL | `8bymr2h348.execute-api.eu-west-3.amazonaws.com` | `05kpv2341k.execute-api.eu-west-3.amazonaws.com` |
| Distribution path | `/dev` | `/prod` |
| Cognito Pool ID | `eu-west-3_ewIR3R9Sl` | `eu-west-3_sZA2GWT5W` |
| Cognito Client ID | `729e89vrtssaguuv0hpdkhs1eg` | `d1lt020mqpfmkq1vkkm0dsgpd` |
| Identity Pool ID | `eu-west-3:a91c68fa-...` | `eu-west-3:59d68e1a-...` |

**Build Flavors:**
- `dev` — no `google-services.json` entry, non-functional
- `prod` — full production configuration, always use `--flavor prod`

---

## 18. Dead Code & Deprecated Systems

### 18.1 Dead Code (No Navigation Path)

| Feature | Code Exists | Why Dead |
|---------|-------------|----------|
| **Liquid Favorites tab** | Screens: `AddLiquidFavoriteScreen`, `CreateNewLiquidFavoriteScreen`, `FavoriteLiquidsScreen` | FavoritesTabHolder only shows 3 tabs (Meal, Physical Activity, Supplements) — no Liquids tab |
| **Subjective Analysis UI** | `SubjectiveAnalysisApi`, interactors, master file | Backend infrastructure only. Zero UI screens. TestBloc has upload code |
| **TestScreen** | Route `/test_screen` registered | Debug screen with no navigation entry point |
| **BarCodeScanningScreen** | Old barcode-only scanner | Replaced by `FoodScannerScreen` (camera-based with visual recognition + barcode) |
| **liquidFavorites sync** | Category exists in EventsSyncApi | Syncs from backend but no way to create in UI (Favorites tab missing) |

### 18.2 Deprecated Lambdas (Computation Moved Client-Side)

| Lambda | Replaced By | Status |
|--------|------------|--------|
| `food-event-amplify-prod` | `NutrientCalculationService` + `save-food-event-prod` | Deprecated 2026-03-04 |
| `sport-event-amplify-prod` | `SportKcalCalculationService` + `save-sport-event-prod` | Deprecated 2026-03-04 |
| `liquid-event-amplify-prod` | `NutrientCalculationService` + `save-liquid-event-prod` | Deprecated 2026-03-04 |
| `upload-profile-data-prod` (old) | `ProfileComputationService` + `save-profile-data-prod` | Deprecated 2026-03-04 |

### 18.3 Known Sync Limitation

The `events-sync-prod` Lambda uses `filterKey: 'eventId'` for ALL 20 categories, but 4 categories use `eventDate` as their unique key (not `eventId`):
- `liquidEvents` — uses eventDate (active in UI)
- `recipeFavorites` — uses eventDate (active in UI)
- `liquidFavorites` — uses eventDate (dead code)
- `subjectiveAnalysis` — uses eventDate (dead code)

This means `liquidEvents` and `recipeFavorites` do not sync cross-device correctly.
