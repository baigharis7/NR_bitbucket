import 'package:flutter_test/flutter_test.dart';
import 'package:health/health.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nutrenaissance_flutter/data/repository/healthsync/health_sync_repository_impl.dart';
import 'package:nutrenaissance_flutter/domain/repository/localstorage/local_storage.dart';
import 'package:nutrenaissance_flutter/domain/repository/preferences/preferences_repository.dart';
import 'package:nutrenaissance_flutter/data/api/sleepevents/sleep_events_api.dart';
import 'package:nutrenaissance_flutter/data/api/steps/steps_api.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/sync_queue_service.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/healthsync/health_platform_client.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/healthsync/health_platform_service.dart';

class _MockLocalStorage extends Mock implements LocalStorageRepository {}

class _MockPreferences extends Mock implements PreferencesRepository {}

class _MockSleepEventsApi extends Mock implements SleepEventsApi {}

class _MockStepsApi extends Mock implements StepsApi {}

class _MockSyncQueue extends Mock implements SyncQueueService {}

/// Fake client keyed by the first requested type (the repo always reads one
/// type per call). Configurable per-method throwing to exercise catch paths.
class _FakeClient implements HealthPlatformClient {
  bool authorizeResult = true;
  bool? hasPermissionsResult = true;
  Object? throwOnAuthorize;
  Object? throwOnHasPermissions;
  Object? throwOnRead;
  final Map<HealthDataType, List<HealthDataPoint>> dataByType = {};

  List<HealthDataType>? lastAuthTypes;
  List<HealthDataAccess>? lastAuthPermissions;
  List<HealthDataType>? lastCheckTypes;
  List<HealthDataAccess>? lastCheckPermissions;
  final List<({List<HealthDataType> types, DateTime start, DateTime end})>
  reads = [];

  @override
  Future<bool> requestAuthorization(
    List<HealthDataType> types, {
    required List<HealthDataAccess> permissions,
  }) async {
    lastAuthTypes = types;
    lastAuthPermissions = permissions;
    if (throwOnAuthorize != null) throw throwOnAuthorize!;
    return authorizeResult;
  }

  @override
  Future<bool?> hasPermissions(
    List<HealthDataType> types, {
    required List<HealthDataAccess> permissions,
  }) async {
    lastCheckTypes = types;
    lastCheckPermissions = permissions;
    if (throwOnHasPermissions != null) throw throwOnHasPermissions!;
    return hasPermissionsResult;
  }

  @override
  Future<List<HealthDataPoint>> getHealthDataFromTypes({
    required List<HealthDataType> types,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    reads.add((types: types, start: startTime, end: endTime));
    if (throwOnRead != null) throw throwOnRead!;
    return dataByType[types.first] ?? [];
  }
}

class _FakeService implements HealthPlatformService {
  // Fields carry defaults; tests mutate them directly after construction.
  @override
  HealthHostPlatform hostPlatform = HealthHostPlatform.android;
  @override
  List<HealthDataType> readTypes = const [
    HealthDataType.WORKOUT,
    HealthDataType.STEPS,
  ];
  @override
  HealthDataType distanceType = HealthDataType.DISTANCE_DELTA;
  @override
  String importedSourceType = 'health_connect';
  bool availableResult = true;
  Object? throwOnAvailable;
  int installCount = 0;
  int openCount = 0;

  @override
  Future<bool> isHealthSyncAvailable() async {
    if (throwOnAvailable != null) throw throwOnAvailable!;
    return availableResult;
  }

  @override
  Future<void> installHealthConnect() async => installCount++;

  @override
  Future<void> openHealthConnect() async => openCount++;
}

/// Builds a raw HealthDataPoint for tests. Mirrors the health package's
/// required fields; unused metadata is defaulted.
HealthDataPoint _point({
  required HealthDataType type,
  required HealthValue value,
  required DateTime from,
  required DateTime to,
  String sourceName = 'TestSource',
}) {
  return HealthDataPoint(
    uuid: '$type-${from.millisecondsSinceEpoch}',
    value: value,
    type: type,
    unit: HealthDataUnit.NO_UNIT,
    dateFrom: from,
    dateTo: to,
    sourcePlatform: HealthPlatformType.appleHealth,
    sourceDeviceId: 'device',
    sourceId: 'source-id',
    sourceName: sourceName,
  );
}

void main() {
  late _MockLocalStorage localStorage;
  late _MockPreferences prefs;
  late _MockSleepEventsApi sleepApi;
  late _MockStepsApi stepsApi;
  late _MockSyncQueue syncQueue;
  late _FakeClient client;
  late _FakeService service;

  HealthSyncRepositoryImpl build() => HealthSyncRepositoryImpl(
    localStorageRepository: localStorage,
    preferencesRepository: prefs,
    sleepEventsApi: sleepApi,
    stepsApi: stepsApi,
    syncQueue: syncQueue,
    healthPlatformClient: client,
    healthPlatformService: service,
  );

  setUp(() {
    localStorage = _MockLocalStorage();
    prefs = _MockPreferences();
    sleepApi = _MockSleepEventsApi();
    stepsApi = _MockStepsApi();
    syncQueue = _MockSyncQueue();
    client = _FakeClient();
    service = _FakeService();
  });

  group('isHealthSyncAvailable', () {
    test('delegates to the service', () async {
      service.availableResult = true;
      expect(await build().isHealthSyncAvailable(), isTrue);
      service.availableResult = false;
      expect(await build().isHealthSyncAvailable(), isFalse);
    });

    test('returns false when the service throws', () async {
      service.throwOnAvailable = Exception('boom');
      expect(await build().isHealthSyncAvailable(), isFalse);
    });
  });

  group('permissions', () {
    test(
      'requestPermissions delegates service types + READ-per-type',
      () async {
        service.readTypes = [HealthDataType.WORKOUT, HealthDataType.STEPS];
        client.authorizeResult = true;
        final result = await build().requestPermissions();
        expect(result, isTrue);
        expect(client.lastAuthTypes, [
          HealthDataType.WORKOUT,
          HealthDataType.STEPS,
        ]);
        expect(client.lastAuthPermissions, [
          HealthDataAccess.READ,
          HealthDataAccess.READ,
        ]);
      },
    );

    test('requestPermissions returns false on client exception', () async {
      client.throwOnAuthorize = Exception('boom');
      expect(await build().requestPermissions(), isFalse);
    });

    test(
      'hasPermissions delegates full readTypes + READ-per-type and returns the result',
      () async {
        service.readTypes = [
          HealthDataType.WORKOUT,
          HealthDataType.STEPS,
          HealthDataType.SLEEP_SESSION,
        ];
        client.hasPermissionsResult = true;
        expect(await build().hasPermissions(), isTrue);
        expect(client.lastCheckTypes, service.readTypes);
        expect(client.lastCheckPermissions, [
          HealthDataAccess.READ,
          HealthDataAccess.READ,
          HealthDataAccess.READ,
        ]);
      },
    );

    test('hasPermissions maps a null result to false', () async {
      client.hasPermissionsResult = null;
      expect(await build().hasPermissions(), isFalse);
    });

    test('hasPermissions returns false on client exception', () async {
      client.throwOnHasPermissions = Exception('boom');
      expect(await build().hasPermissions(), isFalse);
    });
  });

  group('fetchActivities', () {
    test('maps a workout with enrichment and service source type', () async {
      final start = DateTime(2026, 7, 1, 8, 0);
      final end = DateTime(2026, 7, 1, 9, 0);
      service.importedSourceType = 'apple_health';
      service.distanceType = HealthDataType.DISTANCE_WALKING_RUNNING;

      client.dataByType[HealthDataType.WORKOUT] = [
        _point(
          type: HealthDataType.WORKOUT,
          value: WorkoutHealthValue(
            workoutActivityType: HealthWorkoutActivityType.RUNNING,
          ),
          from: start,
          to: end,
          sourceName: 'Apple Watch',
        ),
      ];
      client.dataByType[HealthDataType.ACTIVE_ENERGY_BURNED] = [
        _point(
          type: HealthDataType.ACTIVE_ENERGY_BURNED,
          value: NumericHealthValue(numericValue: 300),
          from: start,
          to: end,
        ),
      ];
      client.dataByType[HealthDataType.DISTANCE_WALKING_RUNNING] = [
        _point(
          type: HealthDataType.DISTANCE_WALKING_RUNNING,
          value: NumericHealthValue(numericValue: 5000),
          from: start,
          to: end,
        ),
      ];
      client.dataByType[HealthDataType.HEART_RATE] = [
        _point(
          type: HealthDataType.HEART_RATE,
          value: NumericHealthValue(numericValue: 150),
          from: start,
          to: end,
        ),
      ];

      final activities = await build().fetchActivities(
        startDate: start,
        endDate: end,
      );

      expect(activities, hasLength(1));
      final a = activities.single;
      expect(a.activityType, 'RUNNING');
      expect(a.startTime, start);
      expect(a.endTime, end);
      expect(a.durationMinutes, 60);
      expect(a.caloriesBurned, 300);
      expect(a.distance, 5000);
      expect(a.avgHeartRate, 150);
      expect(a.sourceName, 'Apple Watch');
      expect(a.sourceType, 'apple_health');
      expect(
        a.healthPlatformId,
        'Apple Watch_${start.millisecondsSinceEpoch}_${end.millisecondsSinceEpoch}',
      );
      // The four reads happen in the expected order, each single-typed (with
      // the service-provided distance type), over the exact requested window.
      expect(client.reads.map((r) => r.types).toList(), [
        [HealthDataType.WORKOUT],
        [HealthDataType.ACTIVE_ENERGY_BURNED],
        [HealthDataType.DISTANCE_WALKING_RUNNING],
        [HealthDataType.HEART_RATE],
      ]);
      expect(
        client.reads.every((r) => r.start == start && r.end == end),
        isTrue,
      );
    });

    test(
      'uses workout built-in energy/distance when enrichment absent',
      () async {
        final start = DateTime(2026, 7, 1, 8, 0);
        final end = DateTime(2026, 7, 1, 8, 30);
        client.dataByType[HealthDataType.WORKOUT] = [
          _point(
            type: HealthDataType.WORKOUT,
            value: WorkoutHealthValue(
              workoutActivityType: HealthWorkoutActivityType.RUNNING,
              totalEnergyBurned: 120,
              totalDistance: 2000,
            ),
            from: start,
            to: end,
          ),
        ];

        final a = (await build().fetchActivities(
          startDate: start,
          endDate: end,
        )).single;
        expect(a.caloriesBurned, 120);
        expect(a.distance, 2000);
        expect(a.avgHeartRate, isNull);
      },
    );

    test('returns [] when the client throws', () async {
      client.throwOnRead = Exception('boom');
      expect(
        await build().fetchActivities(
          startDate: DateTime(2026),
          endDate: DateTime(2026),
        ),
        isEmpty,
      );
    });
  });

  group('fetchTodaySleepHours', () {
    test('sums non-overlapping sleep sessions', () async {
      final date = DateTime(2026, 7, 1);
      client.dataByType[HealthDataType.SLEEP_SESSION] = [
        _point(
          type: HealthDataType.SLEEP_SESSION,
          value: NumericHealthValue(numericValue: 0),
          from: DateTime(2026, 6, 30, 23, 0),
          to: DateTime(2026, 7, 1, 6, 0),
        ),
      ];
      final hours = await build().fetchTodaySleepHours(date);
      expect(hours, closeTo(7.0, 0.001));
    });

    test('returns 0.0 for an empty successful read', () async {
      final hours = await build().fetchTodaySleepHours(DateTime(2026, 7, 1));
      expect(hours, 0.0);
    });

    test('returns null when the client throws', () async {
      client.throwOnRead = Exception('boom');
      expect(await build().fetchTodaySleepHours(DateTime(2026, 7, 1)), isNull);
    });
  });

  group('fetchTodayStepCount', () {
    test('sums numeric step values', () async {
      client.dataByType[HealthDataType.STEPS] = [
        _point(
          type: HealthDataType.STEPS,
          value: NumericHealthValue(numericValue: 1000),
          from: DateTime(2026, 7, 1, 8),
          to: DateTime(2026, 7, 1, 9),
        ),
        _point(
          type: HealthDataType.STEPS,
          value: NumericHealthValue(numericValue: 500),
          from: DateTime(2026, 7, 1, 10),
          to: DateTime(2026, 7, 1, 11),
        ),
      ];
      expect(await build().fetchTodayStepCount(DateTime(2026, 7, 1)), 1500);
    });

    test('returns 0 for an empty successful read', () async {
      expect(await build().fetchTodayStepCount(DateTime(2026, 7, 1)), 0);
    });

    test('returns null when the client throws', () async {
      client.throwOnRead = Exception('boom');
      expect(await build().fetchTodayStepCount(DateTime(2026, 7, 1)), isNull);
    });
  });

  group('Health Connect navigation', () {
    test('installHealthConnect delegates to the service', () async {
      await build().installHealthConnect();
      expect(service.installCount, 1);
    });

    test('openHealthConnect delegates to the service', () async {
      await build().openHealthConnect();
      expect(service.openCount, 1);
    });
  });
}
