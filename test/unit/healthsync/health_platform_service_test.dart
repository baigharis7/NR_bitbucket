import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health/health.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/healthsync/health_platform_service.dart';

const marketUrl = 'market://details?id=com.google.android.apps.healthdata';
const webUrl =
    'https://play.google.com/store/apps/details?id=com.google.android.apps.healthdata';

void main() {
  HealthPlatformServiceImpl build({
    required HealthHostPlatform host,
    Future<bool?> Function(String method)? invokeBool,
    Future<bool> Function(Uri uri)? canLaunch,
    List<({Uri uri, LaunchMode mode})>? launchLog,
  }) {
    return HealthPlatformServiceImpl(
      hostPlatform: host,
      invokeBool: invokeBool ?? (_) async => true,
      canLaunch: canLaunch ?? (_) async => true,
      launch: (uri, {mode = LaunchMode.platformDefault}) async {
        launchLog?.add((uri: uri, mode: mode));
        return true;
      },
    );
  }

  group('platform-specific data', () {
    test('iOS read types include DISTANCE_WALKING_RUNNING, not DELTA', () {
      final s = build(host: HealthHostPlatform.ios);
      expect(s.readTypes, contains(HealthDataType.DISTANCE_WALKING_RUNNING));
      expect(s.readTypes, isNot(contains(HealthDataType.DISTANCE_DELTA)));
      expect(s.distanceType, HealthDataType.DISTANCE_WALKING_RUNNING);
      expect(s.importedSourceType, 'apple_health');
    });

    test('Android read types include DISTANCE_DELTA, not WALKING_RUNNING', () {
      final s = build(host: HealthHostPlatform.android);
      expect(s.readTypes, contains(HealthDataType.DISTANCE_DELTA));
      expect(
        s.readTypes,
        isNot(contains(HealthDataType.DISTANCE_WALKING_RUNNING)),
      );
      expect(s.distanceType, HealthDataType.DISTANCE_DELTA);
      expect(s.importedSourceType, 'health_connect');
    });

    test(
      'unsupported host has no distance type in read list, defaults to DELTA',
      () {
        final s = build(host: HealthHostPlatform.unsupported);
        expect(
          s.readTypes,
          isNot(contains(HealthDataType.DISTANCE_WALKING_RUNNING)),
        );
        expect(s.readTypes, isNot(contains(HealthDataType.DISTANCE_DELTA)));
        expect(s.distanceType, HealthDataType.DISTANCE_DELTA);
        expect(s.importedSourceType, 'health_connect');
      },
    );

    test('base read types are present on every platform', () {
      final s = build(host: HealthHostPlatform.android);
      expect(
        s.readTypes,
        containsAll([
          HealthDataType.WORKOUT,
          HealthDataType.STEPS,
          HealthDataType.ACTIVE_ENERGY_BURNED,
          HealthDataType.HEART_RATE,
          HealthDataType.SLEEP_SESSION,
        ]),
      );
    });

    test(
      'iOS workout totals are session-scoped (genuine per-session HKWorkout totals)',
      () {
        final s = build(host: HealthHostPlatform.ios);
        expect(s.workoutTotalsAreSessionScoped, isTrue);
      },
    );

    test(
      'Android workout totals are NOT session-scoped (plugin window-sums them)',
      () {
        final s = build(host: HealthHostPlatform.android);
        expect(s.workoutTotalsAreSessionScoped, isFalse);
      },
    );

    test('Android optional read types include TOTAL_CALORIES_BURNED', () {
      final s = build(host: HealthHostPlatform.android);
      expect(s.optionalReadTypes, [HealthDataType.TOTAL_CALORIES_BURNED]);
    });

    test('iOS optional read types are empty', () {
      final s = build(host: HealthHostPlatform.ios);
      expect(s.optionalReadTypes, isEmpty);
    });

    test('unsupported host optional read types are empty', () {
      final s = build(host: HealthHostPlatform.unsupported);
      expect(s.optionalReadTypes, isEmpty);
    });
  });

  group('isHealthSyncAvailable', () {
    test('unsupported host returns false without invoking channel', () async {
      var called = false;
      final s = build(
        host: HealthHostPlatform.unsupported,
        invokeBool: (_) async {
          called = true;
          return true;
        },
      );
      expect(await s.isHealthSyncAvailable(), isFalse);
      expect(called, isFalse);
    });

    test('iOS returns true without invoking channel', () async {
      var called = false;
      final s = build(
        host: HealthHostPlatform.ios,
        invokeBool: (_) async {
          called = true;
          return true;
        },
      );
      expect(await s.isHealthSyncAvailable(), isTrue);
      expect(called, isFalse);
    });

    test(
      'Android delegates to native isHealthConnectAvailable = true',
      () async {
        final s = build(
          host: HealthHostPlatform.android,
          invokeBool: (m) async =>
              m == 'isHealthConnectAvailable' ? true : null,
        );
        expect(await s.isHealthSyncAvailable(), isTrue);
      },
    );

    test('Android returns false when native result is false', () async {
      final s = build(
        host: HealthHostPlatform.android,
        invokeBool: (_) async => false,
      );
      expect(await s.isHealthSyncAvailable(), isFalse);
    });

    test('Android returns false when native result is null', () async {
      final s = build(
        host: HealthHostPlatform.android,
        invokeBool: (_) async => null,
      );
      expect(await s.isHealthSyncAvailable(), isFalse);
    });

    test('Android channel exception propagates (repo catches it)', () async {
      final s = build(
        host: HealthHostPlatform.android,
        invokeBool: (_) async => throw PlatformException(code: 'x'),
      );
      expect(s.isHealthSyncAvailable(), throwsA(isA<PlatformException>()));
    });
  });

  group('openHealthConnect', () {
    test('non-Android is a no-op', () async {
      final log = <({Uri uri, LaunchMode mode})>[];
      final s = build(host: HealthHostPlatform.ios, launchLog: log);
      await s.openHealthConnect();
      expect(log, isEmpty);
    });

    test(
      'invokes exactly the openHealthConnect native method and launches no URL on success',
      () async {
        final log = <({Uri uri, LaunchMode mode})>[];
        final methods = <String>[];
        final s = build(
          host: HealthHostPlatform.android,
          invokeBool: (m) async {
            methods.add(m);
            return true;
          },
          launchLog: log,
        );
        await s.openHealthConnect();
        expect(methods, ['openHealthConnect']);
        expect(log, isEmpty);
      },
    );

    test(
      'falls back to the exact market URL when native open returns false',
      () async {
        final log = <({Uri uri, LaunchMode mode})>[];
        final s = build(
          host: HealthHostPlatform.android,
          invokeBool: (_) async => false,
          canLaunch: (_) async => true,
          launchLog: log,
        );
        await s.openHealthConnect();
        expect(log.single.uri.toString(), marketUrl);
      },
    );

    test(
      'falls back to the exact web URL (external) when market cannot launch',
      () async {
        final log = <({Uri uri, LaunchMode mode})>[];
        final s = build(
          host: HealthHostPlatform.android,
          invokeBool: (_) async => false,
          canLaunch: (_) async => false,
          launchLog: log,
        );
        await s.openHealthConnect();
        expect(log.single.uri.toString(), webUrl);
        expect(log.single.mode, LaunchMode.externalApplication);
      },
    );
  });

  group('installHealthConnect', () {
    test('non-Android is a no-op', () async {
      final log = <({Uri uri, LaunchMode mode})>[];
      final s = build(host: HealthHostPlatform.ios, launchLog: log);
      await s.installHealthConnect();
      expect(log, isEmpty);
    });

    test('launches market URL when it can launch', () async {
      final log = <({Uri uri, LaunchMode mode})>[];
      final s = build(
        host: HealthHostPlatform.android,
        canLaunch: (_) async => true,
        launchLog: log,
      );
      await s.installHealthConnect();
      expect(log.single.uri.toString(), marketUrl);
    });

    test(
      'falls back to the exact web URL (external) when market cannot launch',
      () async {
        final log = <({Uri uri, LaunchMode mode})>[];
        final s = build(
          host: HealthHostPlatform.android,
          canLaunch: (_) async => false,
          launchLog: log,
        );
        await s.installHealthConnect();
        expect(log.single.uri.toString(), webUrl);
        expect(log.single.mode, LaunchMode.externalApplication);
      },
    );
  });
}
