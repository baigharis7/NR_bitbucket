import 'package:flutter_test/flutter_test.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/healthsync/health_source_resolver.dart';

void main() {
  group('HealthSourceResolver.resolve', () {
    HealthSourceCategory android(String sourceName) =>
        HealthSourceResolver.resolve(
          sourceName: sourceName,
          sourceType: 'health_connect',
        );
    HealthSourceCategory ios(String sourceName) => HealthSourceResolver.resolve(
      sourceName: sourceName,
      sourceType: 'apple_health',
    );

    test('resolves Android writer package names', () {
      expect(
        android('com.sec.android.app.shealth'),
        HealthSourceCategory.samsungHealth,
      );
      expect(
        android('com.google.android.apps.fitness'),
        HealthSourceCategory.googleFit,
      );
      expect(
        android('com.garmin.android.apps.connectmobile'),
        HealthSourceCategory.garmin,
      );
      expect(android('com.fitbit.FitbitMobile'), HealthSourceCategory.fitbit);
      expect(android('fi.polar.polarflow'), HealthSourceCategory.polar);
      expect(
        android('com.google.android.apps.healthdata'),
        HealthSourceCategory.healthConnectApp,
      );
    });

    test('resolves iOS display names', () {
      expect(ios('Apple Watch'), HealthSourceCategory.appleWatch);
      expect(ios('Samsung Health'), HealthSourceCategory.samsungHealth);
      expect(ios('Garmin Connect'), HealthSourceCategory.garmin);
      expect(ios('Polar Flow'), HealthSourceCategory.polar);
      expect(ios('Fitbit'), HealthSourceCategory.fitbit);
      expect(ios('Apple Health'), HealthSourceCategory.appleHealthApp);
      expect(ios('Health'), HealthSourceCategory.appleHealthApp);
    });

    test('is case-insensitive and trims', () {
      expect(
        android(' COM.SEC.ANDROID.APP.SHEALTH '),
        HealthSourceCategory.samsungHealth,
      );
      expect(ios('apple watch'), HealthSourceCategory.appleWatch);
    });

    test('fitbit wins over the fit keyword', () {
      expect(android('com.fitbit.FitbitMobile'), HealthSourceCategory.fitbit);
      expect(ios('Fitbit'), isNot(HealthSourceCategory.googleFit));
    });

    test('unrecognized names resolve to unknown, never a guess', () {
      expect(android('com.example.unknownapp'), HealthSourceCategory.unknown);
      expect(android(''), HealthSourceCategory.unknown);
      expect(ios('MyRunApp'), HealthSourceCategory.unknown);
    });

    test('the bare Health display name is Apple-only', () {
      expect(android('Health'), HealthSourceCategory.unknown);
    });
  });
}
