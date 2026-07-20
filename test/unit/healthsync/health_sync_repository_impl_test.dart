import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health/health.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nutrenaissance_flutter/data/local/models/healthsync/health_sync_metadata_entity.dart';
import 'package:nutrenaissance_flutter/data/repository/healthsync/health_sync_repository_impl.dart';
import 'package:nutrenaissance_flutter/domain/models/healthsync/health_activity.dart';
import 'package:nutrenaissance_flutter/domain/models/healthsync/health_fetch_result.dart';
import 'package:nutrenaissance_flutter/domain/models/healthsync/health_sync_metadata.dart';
import 'package:nutrenaissance_flutter/domain/repository/localstorage/local_storage.dart';
import 'package:nutrenaissance_flutter/domain/repository/preferences/preferences_repository.dart';
import 'package:nutrenaissance_flutter/data/api/sleepevents/sleep_events_api.dart';
import 'package:nutrenaissance_flutter/data/api/steps/steps_api.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/sync_queue_service.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/healthsync/health_platform_client.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/healthsync/health_platform_service.dart';
import 'package:nutrenaissance_flutter/data/api/sleepevents/models/upload_sleep_event.dart';
import 'package:nutrenaissance_flutter/data/api/steps/models/upload_step_event_response.dart';
import 'package:nutrenaissance_flutter/data/local/models/profile/user_profile_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/sleepevents/sleep_event_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/steps/steps_entity.dart';
import 'package:nutrenaissance_flutter/domain/models/healthsync/health_sync_diagnostic_event.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/healthsync/health_sync_diagnostics_sink.dart';

import '../../support/healthsync/health_data_point_builder.dart';
import '../../support/healthsync/health_source_fixtures.dart';

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
  final Map<HealthDataType, Object> throwByType = {};
  final Map<HealthDataType, List<HealthDataPoint>> dataByType = {};

  /// Defaults to `null` so existing tests exercise the pre-aggregate fallback
  /// path; set to stub the platform's own source-deduped step total.
  int? stepsInIntervalResult;

  List<HealthDataType>? lastAuthTypes;
  List<HealthDataAccess>? lastAuthPermissions;
  List<HealthDataType>? lastCheckTypes;
  List<HealthDataAccess>? lastCheckPermissions;
  final List<({List<HealthDataType> types, DateTime start, DateTime end})>
  reads = [];
  final List<({DateTime start, DateTime end, bool includeManualEntry})>
  stepsInIntervalCalls = [];

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
    final perType = throwByType[types.first];
    if (perType != null) throw perType;
    return dataByType[types.first] ?? [];
  }

  @override
  Future<int?> getTotalStepsInInterval({
    required DateTime startTime,
    required DateTime endTime,
    bool includeManualEntry = true,
  }) async {
    stepsInIntervalCalls.add((
      start: startTime,
      end: endTime,
      includeManualEntry: includeManualEntry,
    ));
    return stepsInIntervalResult;
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

UserProfileEntity profileWithUserId(String? userId) => UserProfileEntity(
  userId: userId,
  commonName: 'Test User',
  birthDate: 0,
  sex: 0,
  occupationActivityFactor: 1.0,
  objectives: const [],
);

void main() {
  late _MockLocalStorage localStorage;
  late _MockPreferences prefs;
  late _MockSleepEventsApi sleepApi;
  late _MockStepsApi stepsApi;
  late _MockSyncQueue syncQueue;
  late _FakeClient client;
  late _FakeService service;
  late InMemoryHealthSyncDiagnosticsSink diagnostics;

  HealthSyncRepositoryImpl build() => HealthSyncRepositoryImpl(
    localStorageRepository: localStorage,
    preferencesRepository: prefs,
    sleepEventsApi: sleepApi,
    stepsApi: stepsApi,
    syncQueue: syncQueue,
    healthPlatformClient: client,
    healthPlatformService: service,
    diagnostics: diagnostics,
  );

  setUpAll(() {
    registerFallbackValue(
      SleepEventEntity(eventDate: 0, eventId: 0, sleepMinutes: 0),
    );
    registerFallbackValue(
      StepsEntity(eventId: 0, initialSteps: 0, actualSteps: 0),
    );
    registerFallbackValue(
      UploadSleepEvent(userId: '', eventId: 0, eventDate: 0, sleepMinutes: 0),
    );
    registerFallbackValue(
      UploadStepEventResponse(
        userId: '',
        eventId: 0,
        initialSteps: 0,
        actualSteps: 0,
      ),
    );
    registerFallbackValue(
      HealthSyncMetadataEntity(
        healthPlatformId: '',
        sportEventId: 0,
        syncedAt: 0,
        sourceType: '',
      ),
    );
  });

  setUp(() {
    localStorage = _MockLocalStorage();
    prefs = _MockPreferences();
    sleepApi = _MockSleepEventsApi();
    stepsApi = _MockStepsApi();
    syncQueue = _MockSyncQueue();
    client = _FakeClient();
    service = _FakeService();
    diagnostics = InMemoryHealthSyncDiagnosticsSink();
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
    test('privacy: fetchTodayStepCount logs no exact step total', () async {
      final captured = <String>[];
      final DebugPrintCallback original = debugPrint;
      debugPrint = (String? message, {int? wrapWidth}) {
        if (message != null) captured.add(message);
      };
      try {
        client.stepsInIntervalResult = 4321;
        final total = await build().fetchTodayStepCount(DateTime(2026, 7, 1));
        expect(total, 4321);
        expect(captured.join('\n'), isNot(contains('4321')));
      } finally {
        debugPrint = original;
      }
    });

    test('privacy: workout mapping logs no exact kcal/distance/heart-rate '
        'values to debugPrint', () async {
      final captured = <String>[];
      final DebugPrintCallback original = debugPrint;
      debugPrint = (String? message, {int? wrapWidth}) {
        if (message != null) captured.add(message);
      };
      try {
        final start = DateTime(2026, 7, 1, 8, 0);
        final end = DateTime(2026, 7, 1, 9, 0);
        client.dataByType[HealthDataType.WORKOUT] = [
          workoutPoint(from: start, to: end, source: appleWatch, uuid: 'wk-priv'),
        ];
        client.dataByType[HealthDataType.ACTIVE_ENERGY_BURNED] = [
          numericPoint(
            type: HealthDataType.ACTIVE_ENERGY_BURNED,
            value: 437,
            from: start,
            to: end,
          ),
        ];

        await build().fetchActivities(startDate: start, endDate: end);

        final joined = captured.join('\n');
        expect(joined, isNot(contains('kcal=')));
        expect(joined, isNot(contains('437'))); // exact enriched kcal
      } finally {
        debugPrint = original;
      }
    });

    test('maps a workout with enrichment and service source type', () async {
      final start = DateTime(2026, 7, 1, 8, 0);
      final end = DateTime(2026, 7, 1, 9, 0);
      service.importedSourceType = 'apple_health';
      service.distanceType = HealthDataType.DISTANCE_WALKING_RUNNING;

      client.dataByType[HealthDataType.WORKOUT] = [
        workoutPoint(
          from: start,
          to: end,
          source: appleWatch,
          uuid: 'wk-uuid-e2e',
        ),
      ];
      client.dataByType[HealthDataType.ACTIVE_ENERGY_BURNED] = [
        numericPoint(
          type: HealthDataType.ACTIVE_ENERGY_BURNED,
          value: 300,
          from: start,
          to: end,
        ),
      ];
      client.dataByType[HealthDataType.DISTANCE_WALKING_RUNNING] = [
        numericPoint(
          type: HealthDataType.DISTANCE_WALKING_RUNNING,
          value: 5000,
          from: start,
          to: end,
        ),
      ];
      client.dataByType[HealthDataType.HEART_RATE] = [
        numericPoint(
          type: HealthDataType.HEART_RATE,
          value: 150,
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
      expect(a.healthPlatformId, 'wk-uuid-e2e');
      expect(
        a.legacyPlatformId,
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
          workoutPoint(
            from: start,
            to: end,
            totalEnergyBurned: 120,
            totalDistance: 2000,
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

  group('fetchActivitiesResult', () {
    test('maps a workout to a success result with the activity', () async {
      final start = DateTime(2026, 7, 1, 8, 0);
      final end = DateTime(2026, 7, 1, 9, 0);
      service.importedSourceType = 'apple_health';
      service.distanceType = HealthDataType.DISTANCE_WALKING_RUNNING;

      client.dataByType[HealthDataType.WORKOUT] = [
        workoutPoint(
          from: start,
          to: end,
          source: appleWatch,
          uuid: 'wk-uuid-typed',
        ),
      ];
      client.dataByType[HealthDataType.ACTIVE_ENERGY_BURNED] = [
        numericPoint(
          type: HealthDataType.ACTIVE_ENERGY_BURNED,
          value: 300,
          from: start,
          to: end,
        ),
      ];
      client.dataByType[HealthDataType.DISTANCE_WALKING_RUNNING] = [
        numericPoint(
          type: HealthDataType.DISTANCE_WALKING_RUNNING,
          value: 5000,
          from: start,
          to: end,
        ),
      ];
      client.dataByType[HealthDataType.HEART_RATE] = [
        numericPoint(
          type: HealthDataType.HEART_RATE,
          value: 150,
          from: start,
          to: end,
        ),
      ];

      final result = await build().fetchActivitiesResult(
        startDate: start,
        endDate: end,
      );

      expect(result.status, HealthFetchStatus.success);
      expect(result.isSuccess, isTrue);
      expect(result.hasData, isTrue);
      expect(result.failureReason, isNull);
      expect(result.data, hasLength(1));
      final a = result.data!.single;
      expect(a.activityType, 'RUNNING');
      expect(a.startTime, start);
      expect(a.endTime, end);
      expect(a.durationMinutes, 60);
      expect(a.caloriesBurned, 300);
      expect(a.distance, 5000);
      expect(a.avgHeartRate, 150);
      expect(a.sourceName, 'Apple Watch');
      expect(a.sourceType, 'apple_health');
      expect(a.healthPlatformId, 'wk-uuid-typed');
      expect(
        a.legacyPlatformId,
        'Apple Watch_${start.millisecondsSinceEpoch}_${end.millisecondsSinceEpoch}',
      );
    });

    test('empty read yields successNoData with empty data', () async {
      final result = await build().fetchActivitiesResult(
        startDate: DateTime(2026, 7, 1),
        endDate: DateTime(2026, 7, 2),
      );
      expect(result.status, HealthFetchStatus.successNoData);
      expect(result.isSuccess, isTrue);
      expect(result.hasData, isFalse);
      expect(result.data, isEmpty);
      expect(result.failureReason, isNull);
    });

    test(
      'generic client exception yields failed with unknown reason',
      () async {
        client.throwOnRead = Exception('boom');
        final result = await build().fetchActivitiesResult(
          startDate: DateTime(2026),
          endDate: DateTime(2026),
        );
        expect(result.status, HealthFetchStatus.failed);
        expect(result.isSuccess, isFalse);
        expect(result.data, isNull);
        expect(result.failureReason, HealthFetchFailureReason.unknown);
        expect(result.failureMessage, Exception('x').runtimeType.toString());
      },
    );

    test(
      'fetchActivities delegates: same activity on data, [] on throw',
      () async {
        final start = DateTime(2026, 7, 1, 8, 0);
        final end = DateTime(2026, 7, 1, 9, 0);
        client.dataByType[HealthDataType.WORKOUT] = [
          workoutPoint(
            from: start,
            to: end,
            source: appleWatch,
            uuid: 'wk-uuid-delegate',
          ),
        ];

        final activities = await build().fetchActivities(
          startDate: start,
          endDate: end,
        );
        expect(activities, hasLength(1));
        expect(activities.single.activityType, 'RUNNING');
        expect(activities.single.healthPlatformId, 'wk-uuid-delegate');

        client.throwOnRead = Exception('boom');
        expect(
          await build().fetchActivities(
            startDate: DateTime(2026),
            endDate: DateTime(2026),
          ),
          isEmpty,
        );
      },
    );

    test('platform uuid becomes healthPlatformId; legacy id preserved', () async {
      final start = DateTime(2026, 7, 1, 8, 0);
      final end = DateTime(2026, 7, 1, 9, 0);
      client.dataByType[HealthDataType.WORKOUT] = [
        workoutPoint(
          from: start,
          to: end,
          source: appleWatch,
          uuid: 'platform-uuid-1',
        ),
      ];

      final result = await build().fetchActivitiesResult(
        startDate: start,
        endDate: end,
      );

      final a = result.data!.single;
      expect(a.healthPlatformId, 'platform-uuid-1');
      expect(
        a.legacyPlatformId,
        'Apple Watch_${start.millisecondsSinceEpoch}_${end.millisecondsSinceEpoch}',
      );
    });

    test('empty uuid falls back to the synthesized legacy id', () async {
      final start = DateTime(2026, 7, 1, 8, 0);
      final end = DateTime(2026, 7, 1, 9, 0);
      client.dataByType[HealthDataType.WORKOUT] = [
        workoutPoint(from: start, to: end, source: appleWatch, uuid: ''),
      ];

      final result = await build().fetchActivitiesResult(
        startDate: start,
        endDate: end,
      );

      final a = result.data!.single;
      final legacy =
          'Apple Watch_${start.millisecondsSinceEpoch}_${end.millisecondsSinceEpoch}';
      expect(a.healthPlatformId, legacy);
      expect(a.legacyPlatformId, legacy);
    });

    test(
      'Android package-name source with empty sourceId maps cleanly',
      () async {
        final start = DateTime(2026, 7, 1, 8, 0);
        final end = DateTime(2026, 7, 1, 9, 0);
        client.dataByType[HealthDataType.WORKOUT] = [
          workoutPoint(
            from: start,
            to: end,
            source: samsungHealthPackage,
            uuid: 'hc-record-uuid',
          ),
        ];

        final result = await build().fetchActivitiesResult(
          startDate: start,
          endDate: end,
        );

        final a = result.data!.single;
        expect(a.healthPlatformId, 'hc-record-uuid');
        expect(a.sourceName, 'com.sec.android.app.shealth');
        expect(
          a.legacyPlatformId,
          'com.sec.android.app.shealth_${start.millisecondsSinceEpoch}_${end.millisecondsSinceEpoch}',
        );
      },
    );
  });

  group('fetchActivitiesResult failure classification', () {
    Future<HealthFetchResult<List<HealthActivity>>> fetch() =>
        build().fetchActivitiesResult(
          startDate: DateTime(2026, 7, 1),
          endDate: DateTime(2026, 7, 2),
        );

    test(
      'permission-worded primary-read error yields permissionDenied',
      () async {
        client.throwByType[HealthDataType.WORKOUT] = Exception(
          'READ_WORKOUT permission denied',
        );

        final result = await fetch();

        expect(result.status, HealthFetchStatus.permissionDenied);
        expect(result.data, isNull);
        expect(result.failureReason, HealthFetchFailureReason.permission);
        expect(result.failureMessage, Exception('x').runtimeType.toString());
      },
    );

    test(
      'unavailable-worded primary-read error yields platformUnavailable',
      () async {
        client.throwByType[HealthDataType.WORKOUT] = Exception(
          'Health Connect is unavailable',
        );

        final result = await fetch();

        expect(result.status, HealthFetchStatus.platformUnavailable);
        expect(result.data, isNull);
        expect(
          result.failureReason,
          HealthFetchFailureReason.platformUnavailable,
        );
      },
    );

    test(
      'TimeoutException on the primary read yields failed(timeout)',
      () async {
        client.throwByType[HealthDataType.WORKOUT] = TimeoutException('slow');

        final result = await fetch();

        expect(result.status, HealthFetchStatus.failed);
        expect(result.failureReason, HealthFetchFailureReason.timeout);
        expect(result.failureMessage, 'TimeoutException');
      },
    );

    test(
      'plugin-worded primary-read error yields failed(pluginError)',
      () async {
        client.throwByType[HealthDataType.WORKOUT] = Exception(
          'MissingPluginException: no implementation found',
        );

        final result = await fetch();

        expect(result.status, HealthFetchStatus.failed);
        expect(result.failureReason, HealthFetchFailureReason.pluginError);
      },
    );

    test(
      'fetchActivities parity: classified failures still return []',
      () async {
        client.throwByType[HealthDataType.WORKOUT] = Exception(
          'READ_WORKOUT permission denied',
        );
        expect(
          await build().fetchActivities(
            startDate: DateTime(2026, 7, 1),
            endDate: DateTime(2026, 7, 2),
          ),
          isEmpty,
        );
      },
    );
  });

  group('fetchActivitiesResult enrichment guards', () {
    final start = DateTime(2026, 7, 1, 8, 0);
    final end = DateTime(2026, 7, 1, 9, 0);

    void seedWorkout() {
      client.dataByType[HealthDataType.WORKOUT] = [
        workoutPoint(
          from: start,
          to: end,
          source: appleWatch,
          totalEnergyBurned: 120,
          totalDistance: 2000,
        ),
      ];
    }

    Future<HealthFetchResult<List<HealthActivity>>> fetch() =>
        build().fetchActivitiesResult(startDate: start, endDate: end);

    test('enrichment failure with workouts yields partialSuccess with the '
        'mapped reason and workout built-in fallbacks', () async {
      seedWorkout();
      client.throwByType[HealthDataType.ACTIVE_ENERGY_BURNED] =
          TimeoutException('slow');

      final result = await fetch();

      expect(result.status, HealthFetchStatus.partialSuccess);
      expect(result.isSuccess, isFalse);
      expect(result.failureReason, HealthFetchFailureReason.timeout);
      expect(result.failureMessage, 'TimeoutException');
      expect(result.data, hasLength(1));
      final a = result.data!.single;
      // Enrichment list was empty → _mapWorkoutsToActivities falls back to
      // the workout record's built-in energy/distance; no HR data → null.
      expect(a.caloriesBurned, 120);
      expect(a.distance, 2000);
      expect(a.avgHeartRate, isNull);
    });

    test('records the FIRST enrichment failure when several fail', () async {
      seedWorkout();
      // Reads run workout → energy → distance → heart rate; energy fails
      // first with a permission-worded error, heart rate later with timeout.
      client.throwByType[HealthDataType.ACTIVE_ENERGY_BURNED] = Exception(
        'permission denied',
      );
      client.throwByType[HealthDataType.HEART_RATE] = TimeoutException('slow');

      final result = await fetch();

      expect(result.status, HealthFetchStatus.partialSuccess);
      expect(result.failureReason, HealthFetchFailureReason.permission);
    });

    test(
      'all four reads are attempted despite an enrichment failure',
      () async {
        seedWorkout();
        client.throwByType[HealthDataType.ACTIVE_ENERGY_BURNED] = Exception(
          'boom',
        );

        await fetch();

        expect(client.reads.map((r) => r.types).toList(), [
          [HealthDataType.WORKOUT],
          [HealthDataType.ACTIVE_ENERGY_BURNED],
          [HealthDataType.DISTANCE_DELTA],
          [HealthDataType.HEART_RATE],
        ]);
      },
    );

    test(
      'zero workouts with a failing enrichment read yields successNoData',
      () async {
        client.throwByType[HealthDataType.HEART_RATE] = Exception('boom');

        final result = await fetch();

        expect(result.status, HealthFetchStatus.successNoData);
        expect(result.isSuccess, isTrue);
        expect(result.data, isEmpty);
        expect(result.failureReason, isNull);
      },
    );

    test(
      'fetchActivities parity: partialSuccess still returns the workouts',
      () async {
        seedWorkout();
        client.throwByType[HealthDataType.HEART_RATE] = Exception('boom');

        final activities = await build().fetchActivities(
          startDate: start,
          endDate: end,
        );

        expect(activities, hasLength(1));
        expect(activities.single.activityType, 'RUNNING');
      },
    );
  });

  group('health sync metadata persistence', () {
    test('saveHealthSyncMetadata persists the fingerprint fields', () async {
      when(
        () => localStorage.saveHealthSyncMetadata(any()),
      ).thenAnswer((_) async {});

      await build().saveHealthSyncMetadata(
        HealthSyncMetadata(
          healthPlatformId: 'uuid_1',
          sportEventId: 11,
          syncedAt: DateTime(2026, 7, 18, 10, 0),
          sourceType: 'health_connect',
          normalizedType: 'RUNNING',
          startTimeMs: 1000000000000,
          endTimeMs: 1000003600000,
          sourceCategory: 'googleFit',
        ),
      );

      final entity =
          verify(
                () => localStorage.saveHealthSyncMetadata(captureAny()),
              ).captured.single
              as HealthSyncMetadataEntity;
      expect(entity.healthPlatformId, 'uuid_1');
      expect(entity.sportEventId, 11);
      expect(entity.sourceType, 'health_connect');
      expect(entity.normalizedType, 'RUNNING');
      expect(entity.startTimeMs, 1000000000000);
      expect(entity.endTimeMs, 1000003600000);
      expect(entity.sourceCategory, 'googleFit');
    });

    test(
      'getSyncedMetadata reads fingerprint fields and legacy nulls',
      () async {
        when(() => localStorage.getHealthSyncMetadata()).thenAnswer(
          (_) async => [
            HealthSyncMetadataEntity(
              healthPlatformId: 'uuid_1',
              sportEventId: 11,
              syncedAt: 1752800000000,
              sourceType: 'health_connect',
              normalizedType: 'RUNNING',
              startTimeMs: 1000000000000,
              endTimeMs: 1000003600000,
              sourceCategory: 'googleFit',
            ),
            HealthSyncMetadataEntity(
              healthPlatformId: 'Old Source_1_2',
              sportEventId: 12,
              syncedAt: 1752800000000,
              sourceType: 'apple_health',
            ),
          ],
        );

        final metadata = await build().getSyncedMetadata();

        expect(metadata, hasLength(2));
        expect(metadata[0].normalizedType, 'RUNNING');
        expect(metadata[0].startTimeMs, 1000000000000);
        expect(metadata[0].endTimeMs, 1000003600000);
        expect(metadata[0].sourceCategory, 'googleFit');
        expect(metadata[1].normalizedType, isNull);
        expect(metadata[1].startTimeMs, isNull);
        expect(metadata[1].endTimeMs, isNull);
        expect(metadata[1].sourceCategory, isNull);
      },
    );

    test(
      'saveHealthSyncMetadata writes deletedAtMs null for a fresh import',
      () async {
        when(
          () => localStorage.saveHealthSyncMetadata(any()),
        ).thenAnswer((_) async {});

        await build().saveHealthSyncMetadata(
          HealthSyncMetadata(
            healthPlatformId: 'uuid_2',
            sportEventId: 21,
            syncedAt: DateTime(2026, 7, 18, 10, 0),
            sourceType: 'health_connect',
          ),
        );

        final entity =
            verify(
                  () => localStorage.saveHealthSyncMetadata(captureAny()),
                ).captured.single
                as HealthSyncMetadataEntity;
        expect(entity.deletedAtMs, isNull);
      },
    );

    test(
      'getSyncedMetadata maps a tombstoned entity to isDeleted true',
      () async {
        when(() => localStorage.getHealthSyncMetadata()).thenAnswer(
          (_) async => [
            HealthSyncMetadataEntity(
              healthPlatformId: 'uuid_3',
              sportEventId: 31,
              syncedAt: 1752800000000,
              sourceType: 'apple_health',
              deletedAtMs: 1752900000000,
            ),
          ],
        );

        final metadata = await build().getSyncedMetadata();

        expect(metadata.single.isDeleted, isTrue);
        expect(
          metadata.single.deletedAt,
          DateTime.fromMillisecondsSinceEpoch(1752900000000),
        );
      },
    );
  });

  group('fetchTodaySleepHours', () {
    test('sums non-overlapping sleep sessions', () async {
      final date = DateTime(2026, 7, 1);
      client.dataByType[HealthDataType.SLEEP_SESSION] = [
        sleepPoint(
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

    test(
      'drops a lower-priority planned/scheduled session in favor of a '
      'higher-priority real session, and emits sourceSelected with the '
      'discarded count',
      () async {
        client.dataByType[HealthDataType.SLEEP_SESSION] = [
          // Samsung Health's own "scheduled sleep" goal window — lower
          // priority than a dedicated wearable.
          sleepPoint(
            from: DateTime(2026, 6, 30, 22, 0),
            to: DateTime(2026, 7, 1, 8, 0),
            source: samsungHealth,
          ),
          // Apple Watch's real recorded sleep — higher priority.
          sleepPoint(
            from: DateTime(2026, 6, 30, 23, 0),
            to: DateTime(2026, 7, 1, 6, 0),
            source: appleWatch,
          ),
        ];

        final hours = await build().fetchTodaySleepHours(
          DateTime(2026, 7, 1),
        );

        // Apple Watch's own session wins; Samsung's planned window is
        // discarded rather than summed in.
        expect(hours, closeTo(7.0, 0.001));
        expect(diagnostics.events, hasLength(1));
        final event = diagnostics.events.single;
        expect(event.type, HealthSyncDiagnosticType.sourceSelected);
        expect(event.domain, HealthSyncDomain.sleep);
        expect(event.metadata['sourceCount'], 2);
        expect(event.metadata['discardedCount'], 1);
        expect(event.metadata['selectedCategory'], 'wearable');
        expect(event.metadata.keys, {
          'sourceCount',
          'discardedCount',
          'selectedCategory',
        });
      },
    );

    test(
      'overlapping same-source sessions are unioned, not summed '
      '(regression)',
      () async {
        client.dataByType[HealthDataType.SLEEP_SESSION] = [
          sleepPoint(
            from: DateTime(2026, 6, 30, 23, 0),
            to: DateTime(2026, 7, 1, 6, 0),
            source: appleWatch,
          ),
          sleepPoint(
            from: DateTime(2026, 7, 1, 5, 30),
            to: DateTime(2026, 7, 1, 6, 30),
            source: appleWatch,
          ),
        ];

        final hours = await build().fetchTodaySleepHours(
          DateTime(2026, 7, 1),
        );

        // Union of [23:00,06:00) and [05:30,06:30) = [23:00,06:30) = 7.5h,
        // NOT the naive sum of 7h + 1h = 8h.
        expect(hours, closeTo(7.5, 0.001));
      },
    );

    test(
      'privacy: no raw source name or ISO timestamp is logged per sleep '
      'session, and the sourceSelected diagnostic carries only sanitized '
      'metadata',
      () async {
        // The old per-session Crashlytics loop (source=/from=/to=) and its
        // raw summary line must be gone from source — not just unreached.
        final source = File(
          'lib/data/repository/healthsync/health_sync_repository_impl.dart',
        ).readAsStringSync();
        expect(source.contains('HealthSync sleep session'), isFalse);
        expect(source.contains('HealthSync sleep merged'), isFalse);
        expect(source.contains('point.sourceName'), isFalse);

        client.dataByType[HealthDataType.SLEEP_SESSION] = [
          sleepPoint(
            from: DateTime(2026, 6, 30, 23, 0),
            to: DateTime(2026, 7, 1, 6, 0),
            source: appleWatch,
          ),
        ];

        await build().fetchTodaySleepHours(DateTime(2026, 7, 1));

        expect(diagnostics.events, hasLength(1));
        final event = diagnostics.events.single;
        expect(event.type, HealthSyncDiagnosticType.sourceSelected);
        expect(event.metadata.keys, {
          'sourceCount',
          'discardedCount',
          'selectedCategory',
        });
      },
    );
  });

  group('fetchTodayStepCount', () {
    test('sums numeric step values', () async {
      client.dataByType[HealthDataType.STEPS] = [
        numericPoint(
          type: HealthDataType.STEPS,
          value: 1000,
          from: DateTime(2026, 7, 1, 8),
          to: DateTime(2026, 7, 1, 9),
        ),
        numericPoint(
          type: HealthDataType.STEPS,
          value: 500,
          from: DateTime(2026, 7, 1, 10),
          to: DateTime(2026, 7, 1, 11),
        ),
      ];
      expect(await build().fetchTodayStepCount(DateTime(2026, 7, 1)), 1500);
    });

    test('returns 0 for an empty successful read and emits no sourceSelected '
        'diagnostic (nothing was selected)', () async {
      expect(await build().fetchTodayStepCount(DateTime(2026, 7, 1)), 0);
      expect(diagnostics.events, isEmpty);
    });

    test('returns null when the client throws', () async {
      client.throwOnRead = Exception('boom');
      expect(await build().fetchTodayStepCount(DateTime(2026, 7, 1)), isNull);
    });

    test('platform aggregate present returns the aggregate total, not the raw '
        'sum of overlapping records', () async {
      client.stepsInIntervalResult = 4200;
      client.dataByType[HealthDataType.STEPS] = [
        numericPoint(
          type: HealthDataType.STEPS,
          value: 1000,
          from: DateTime(2026, 7, 1, 8),
          to: DateTime(2026, 7, 1, 9),
          source: appleWatch,
        ),
        numericPoint(
          type: HealthDataType.STEPS,
          value: 900,
          from: DateTime(2026, 7, 1, 8, 5),
          to: DateTime(2026, 7, 1, 9, 5),
          source: iphone,
        ),
      ];

      final total = await build().fetchTodayStepCount(DateTime(2026, 7, 1));

      expect(total, 4200);
      expect(client.stepsInIntervalCalls, hasLength(1));
      expect(client.stepsInIntervalCalls.single.start, DateTime(2026, 7, 1));
      // Half-open day window: [midnight, next-midnight) — no 1-second gap
      // before midnight, and DST-safe via calendar-day arithmetic.
      expect(
        client.stepsInIntervalCalls.single.end,
        DateTime(2026, 7, 2),
      );
    });

    test('aggregate null with overlapping cross-source records falls back to '
        'the highest-priority source total and emits a sourceSelected '
        'diagnostic', () async {
      client.stepsInIntervalResult = null;
      client.dataByType[HealthDataType.STEPS] = [
        numericPoint(
          type: HealthDataType.STEPS,
          value: 1000,
          from: DateTime(2026, 7, 1, 8),
          to: DateTime(2026, 7, 1, 9),
          source: appleWatch,
        ),
        numericPoint(
          type: HealthDataType.STEPS,
          value: 900,
          from: DateTime(2026, 7, 1, 8, 5),
          to: DateTime(2026, 7, 1, 9, 5),
          source: iphone,
        ),
      ];

      final total = await build().fetchTodayStepCount(DateTime(2026, 7, 1));

      // Apple Watch outranks the iPhone's own Apple Health app entry.
      expect(total, 1000);
      expect(diagnostics.events, hasLength(1));
      final event = diagnostics.events.single;
      expect(event.type, HealthSyncDiagnosticType.sourceSelected);
      expect(event.domain, HealthSyncDomain.steps);
      expect(event.metadata['sourceCount'], 2);
      expect(event.metadata['discardedCount'], 1);
      expect(event.metadata['selectedCategory'], 'wearable');
      expect(event.metadata.keys, {
        'sourceCount',
        'discardedCount',
        'selectedCategory',
      });
    });

    test(
      'empty successful read with no platform aggregate returns 0 and emits '
      'no sourceSelected diagnostic',
      () async {
        client.stepsInIntervalResult = null;
        expect(await build().fetchTodayStepCount(DateTime(2026, 7, 1)), 0);
        expect(diagnostics.events, isEmpty);
      },
    );
  });

  group('saveSleepEvent', () {
    final date = DateTime(2026, 7, 18, 14, 30);
    final midnight = DateTime(2026, 7, 18).millisecondsSinceEpoch;

    setUp(() {
      when(() => localStorage.saveSleepEvent(any())).thenAnswer((_) async {});
      when(
        () => sleepApi.uploadSleepEvent(any()),
      ).thenAnswer((_) async => <String, dynamic>{});
    });

    test('valid user ID saves locally AND uploads with that ID', () async {
      when(
        () => localStorage.getProfile(),
      ).thenAnswer((_) async => profileWithUserId('user-42'));

      await build().saveSleepEvent(date: date, sleepHours: 7.5);
      await pumpEventQueue();

      final saved =
          verify(
                () => localStorage.saveSleepEvent(captureAny()),
              ).captured.single
              as SleepEventEntity;
      expect(saved.userId, 'user-42');
      expect(saved.eventDate, midnight);
      expect(saved.eventId, midnight);
      expect(saved.sleepMinutes, 450);

      final uploaded =
          verify(() => sleepApi.uploadSleepEvent(captureAny())).captured.single
              as UploadSleepEvent;
      expect(uploaded.userId, 'user-42');
      expect(uploaded.eventId, midnight);
      expect(uploaded.eventDate, midnight);
      expect(uploaded.sleepMinutes, 450);

      verifyNever(() => syncQueue.enqueue(any(), any()));
      expect(diagnostics.events, isEmpty);
    });

    test(
      'missing profile: local save still happens, upload API is NOT called',
      () async {
        when(() => localStorage.getProfile()).thenAnswer((_) async => null);

        await build().saveSleepEvent(date: date, sleepHours: 8);
        await pumpEventQueue();

        final saved =
            verify(
                  () => localStorage.saveSleepEvent(captureAny()),
                ).captured.single
                as SleepEventEntity;
        // Locked decision: the local entity keeps today's shape — empty
        // string when identity is missing; the next periodic cycle re-saves
        // the same midnight eventId with the repaired identity.
        expect(saved.userId, '');
        expect(saved.eventId, midnight);
        expect(saved.sleepMinutes, 480);

        verifyNever(() => sleepApi.uploadSleepEvent(any()));
        verifyNever(() => syncQueue.enqueue(any(), any()));
      },
    );

    test(
      'empty-string userId: local save still happens, upload API is NOT called',
      () async {
        when(
          () => localStorage.getProfile(),
        ).thenAnswer((_) async => profileWithUserId(''));

        await build().saveSleepEvent(date: date, sleepHours: 8);
        await pumpEventQueue();

        verify(() => localStorage.saveSleepEvent(any())).called(1);
        verifyNever(() => sleepApi.uploadSleepEvent(any()));
        verifyNever(() => syncQueue.enqueue(any(), any()));
      },
    );

    test('missing user ID never enqueues /sleep-event even with the upload '
        'primed to fail', () async {
      when(() => localStorage.getProfile()).thenAnswer((_) async => null);
      when(() => sleepApi.uploadSleepEvent(any())).thenAnswer(
        (_) => Future<Map<String, dynamic>>.error(Exception('boom')),
      );

      await build().saveSleepEvent(date: date, sleepHours: 8);
      await pumpEventQueue();

      verifyNever(() => sleepApi.uploadSleepEvent(any()));
      verifyNever(() => syncQueue.enqueue('/sleep-event', any()));
    });

    test(
      'missing user ID emits identityMissing with the sleep domain',
      () async {
        when(() => localStorage.getProfile()).thenAnswer((_) async => null);

        await build().saveSleepEvent(date: date, sleepHours: 8);

        expect(diagnostics.events, hasLength(1));
        final event = diagnostics.events.single;
        expect(event.type, HealthSyncDiagnosticType.identityMissing);
        expect(event.severity, HealthSyncDiagnosticSeverity.warning);
        expect(event.domain, HealthSyncDomain.sleep);
        expect(event.platform, isNull);
        expect(event.metadata, isEmpty);
      },
    );

    test(
      'valid user ID upload failure still enqueues /sleep-event (regression)',
      () async {
        when(
          () => localStorage.getProfile(),
        ).thenAnswer((_) async => profileWithUserId('user-42'));
        when(() => sleepApi.uploadSleepEvent(any())).thenAnswer(
          (_) => Future<Map<String, dynamic>>.error(Exception('boom')),
        );

        await build().saveSleepEvent(date: date, sleepHours: 8);
        await pumpEventQueue();

        final enqueued =
            verify(
                  () => syncQueue.enqueue('/sleep-event', captureAny()),
                ).captured.single
                as UploadSleepEvent;
        expect(enqueued.userId, 'user-42');
        expect(enqueued.eventId, midnight);
        expect(diagnostics.events, isEmpty);
      },
    );

    test('omitting the diagnostics param defaults to the Noop sink', () async {
      when(() => localStorage.getProfile()).thenAnswer((_) async => null);

      final repo = HealthSyncRepositoryImpl(
        localStorageRepository: localStorage,
        preferencesRepository: prefs,
        sleepEventsApi: sleepApi,
        stepsApi: stepsApi,
        syncQueue: syncQueue,
        healthPlatformClient: client,
        healthPlatformService: service,
      );
      // Must not throw: the guard still blocks the upload silently.
      await repo.saveSleepEvent(date: date, sleepHours: 8);

      verifyNever(() => sleepApi.uploadSleepEvent(any()));
    });
  });

  group('saveStepEvent', () {
    final date = DateTime(2026, 7, 18, 14, 30);
    final midnight = DateTime(2026, 7, 18).millisecondsSinceEpoch;

    setUp(() {
      when(() => localStorage.saveSteps(any())).thenAnswer((_) async {});
      when(
        () => stepsApi.uploadSteps(any()),
      ).thenAnswer((_) async => <String, dynamic>{});
    });

    test('valid user ID saves locally AND uploads with that ID', () async {
      when(
        () => localStorage.getProfile(),
      ).thenAnswer((_) async => profileWithUserId('user-42'));

      await build().saveStepEvent(date: date, stepCount: 4321);
      await pumpEventQueue();

      // StepsEntity carries no userId at all — identity is upload-only.
      final saved =
          verify(() => localStorage.saveSteps(captureAny())).captured.single
              as StepsEntity;
      expect(saved.eventId, midnight);
      expect(saved.initialSteps, 0);
      expect(saved.actualSteps, 4321);

      final uploaded =
          verify(() => stepsApi.uploadSteps(captureAny())).captured.single
              as UploadStepEventResponse;
      expect(uploaded.userId, 'user-42');
      expect(uploaded.eventId, midnight);
      expect(uploaded.initialSteps, 0);
      expect(uploaded.actualSteps, 4321);

      verifyNever(() => syncQueue.enqueue(any(), any()));
      expect(diagnostics.events, isEmpty);
    });

    test(
      'missing profile: local save still happens, upload API is NOT called',
      () async {
        when(() => localStorage.getProfile()).thenAnswer((_) async => null);

        await build().saveStepEvent(date: date, stepCount: 4321);
        await pumpEventQueue();

        final saved =
            verify(() => localStorage.saveSteps(captureAny())).captured.single
                as StepsEntity;
        expect(saved.eventId, midnight);
        expect(saved.actualSteps, 4321);

        verifyNever(() => stepsApi.uploadSteps(any()));
        verifyNever(() => syncQueue.enqueue(any(), any()));
      },
    );

    test(
      'empty-string userId: local save still happens, upload API is NOT called',
      () async {
        when(
          () => localStorage.getProfile(),
        ).thenAnswer((_) async => profileWithUserId(''));

        await build().saveStepEvent(date: date, stepCount: 4321);
        await pumpEventQueue();

        verify(() => localStorage.saveSteps(any())).called(1);
        verifyNever(() => stepsApi.uploadSteps(any()));
        verifyNever(() => syncQueue.enqueue(any(), any()));
      },
    );

    test('missing user ID never enqueues /steps-count even with the upload '
        'primed to fail', () async {
      when(() => localStorage.getProfile()).thenAnswer((_) async => null);
      when(() => stepsApi.uploadSteps(any())).thenAnswer(
        (_) => Future<Map<String, dynamic>>.error(Exception('boom')),
      );

      await build().saveStepEvent(date: date, stepCount: 4321);
      await pumpEventQueue();

      verifyNever(() => stepsApi.uploadSteps(any()));
      verifyNever(() => syncQueue.enqueue('/steps-count', any()));
    });

    test(
      'missing user ID emits identityMissing with the steps domain',
      () async {
        when(() => localStorage.getProfile()).thenAnswer((_) async => null);

        await build().saveStepEvent(date: date, stepCount: 4321);

        expect(diagnostics.events, hasLength(1));
        final event = diagnostics.events.single;
        expect(event.type, HealthSyncDiagnosticType.identityMissing);
        expect(event.severity, HealthSyncDiagnosticSeverity.warning);
        expect(event.domain, HealthSyncDomain.steps);
        expect(event.platform, isNull);
        expect(event.metadata, isEmpty);
      },
    );

    test(
      'valid user ID upload failure still enqueues /steps-count (regression)',
      () async {
        when(
          () => localStorage.getProfile(),
        ).thenAnswer((_) async => profileWithUserId('user-42'));
        when(() => stepsApi.uploadSteps(any())).thenAnswer(
          (_) => Future<Map<String, dynamic>>.error(Exception('boom')),
        );

        await build().saveStepEvent(date: date, stepCount: 4321);
        await pumpEventQueue();

        final enqueued =
            verify(
                  () => syncQueue.enqueue('/steps-count', captureAny()),
                ).captured.single
                as UploadStepEventResponse;
        expect(enqueued.userId, 'user-42');
        expect(enqueued.eventId, midnight);
        expect(diagnostics.events, isEmpty);
      },
    );
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
