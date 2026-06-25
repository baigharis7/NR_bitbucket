# NutRenaissance — Architecture Summary

> Personalized nutrition and health tracking app. Flutter client (Android/iOS)
> + AWS serverless backend (eu-west-3).

## At a glance

- **Client:** Flutter with BLoC; Clean Architecture across 4 layers
  (Presentation → Domain → Data → Infrastructure).
- **Backend:** AWS serverless — API Gateway + Lambda + DynamoDB + S3,
  Cognito for auth, FCM for push.
- **Local storage:** Hive (key-value) + Drift (SQL reference data) +
  SharedPreferences.

## Design principles

1. **Offline-first** — every write hits local storage first; the network is
   async with a retry queue.
2. **Client-side computation** — nutrient, kcal, BMR/RDA and recommendation
   logic run on-device (Dart).
3. **Reactive, decoupled UI** — BLoCs communicate through an event bus, never
   directly with each other.
4. **Constructor-based DI** — all wiring is manual in `app_bootstrap.dart`;
   no service locator.

## Everything targets PROD

The app is wired to the production environment by default:

- **Always build and run with `--flavor prod`.** The `dev` flavor has no
  `google-services.json` and is non-functional (Firebase disabled).
- **Prod API Gateway and prod Cognito pool** are the live configuration
  (`lib/infrastructure/environment/environment.dart`).
- Releases ship from `prod`: signed APK/IPA → Google Play / App Store.
