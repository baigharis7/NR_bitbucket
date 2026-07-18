/// Coarse category of the app/device that wrote a health record. Retained in
/// sync metadata and diagnostics INSTEAD of raw source names — never store or
/// log the raw name downstream of this resolver.
enum HealthSourceCategory {
  samsungHealth,
  googleFit,
  garmin,
  fitbit,
  polar,
  appleWatch,
  appleHealthApp,
  healthConnectApp,
  unknown,
}

/// Resolves a platform source into a coarse [HealthSourceCategory] via a
/// case-insensitive keyword table.
///
/// Platform reality this encodes (verified against health 13.1.4):
/// - Android (Health Connect): `sourceName` is the WRITER'S PACKAGE NAME
///   (e.g. `com.sec.android.app.shealth`); `sourceId` is always `''`.
/// - iOS (HealthKit): `sourceName` is a human display name ("Apple Watch").
///
/// [sourceType] is the app-level platform tag (`'apple_health'` /
/// `'health_connect'`, i.e. [HealthActivity.sourceType]) and only
/// disambiguates the platform-app buckets. Unrecognized input resolves to
/// [HealthSourceCategory.unknown] — never a guess.
class HealthSourceResolver {
  const HealthSourceResolver._();

  static HealthSourceCategory resolve({
    required String sourceName,
    required String sourceType,
  }) {
    final name = sourceName.trim().toLowerCase();
    // Vendor keywords first; ordered so the more specific token wins
    // (fitbit before the google-fit check, health connect before it too).
    if (name.contains('shealth') || name.contains('samsung')) {
      return HealthSourceCategory.samsungHealth;
    }
    if (name.contains('fitbit')) return HealthSourceCategory.fitbit;
    if (name.contains('garmin')) return HealthSourceCategory.garmin;
    if (name.contains('polar')) return HealthSourceCategory.polar;
    if (name.contains('healthdata') || // com.google.android.apps.healthdata
        name.contains('health connect') ||
        name.contains('healthconnect')) {
      return HealthSourceCategory.healthConnectApp;
    }
    if (name.contains('google') && name.contains('fit')) {
      return HealthSourceCategory.googleFit;
    }
    if (name.contains('apple watch') || name == 'watch') {
      return HealthSourceCategory.appleWatch;
    }
    if (sourceType == 'apple_health' &&
        (name == 'health' ||
            name.contains('apple health') ||
            name.contains('iphone') ||
            name.contains('com.apple.health'))) {
      return HealthSourceCategory.appleHealthApp;
    }
    return HealthSourceCategory.unknown;
  }
}
