import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:nutrenaissance_flutter/data/local/models/healthsync/health_sync_metadata_entity.dart';
import 'package:nutrenaissance_flutter/data/repository/localstorage/local_storage_impl.dart';

void main() {
  late LocalStorageImpl storage;

  setUpAll(() {
    Hive.init(
      Directory.systemTemp.createTempSync('nn_health_sync_metadata_test').path,
    );
    Hive.registerAdapter(HealthSyncMetadataEntityAdapter());
  });

  setUp(() async {
    storage = LocalStorageImpl();
    final box = await Hive.openBox(HealthSyncMetadataEntity.boxName);
    await box.clear();
  });

  tearDownAll(() async {
    await Hive.deleteFromDisk();
  });

  HealthSyncMetadataEntity anEntity({
    required String healthPlatformId,
    required int sportEventId,
    int? deletedAtMs,
  }) {
    return HealthSyncMetadataEntity(
      healthPlatformId: healthPlatformId,
      sportEventId: sportEventId,
      syncedAt: DateTime(2026, 7, 18).millisecondsSinceEpoch,
      sourceType: 'health_connect',
      deletedAtMs: deletedAtMs,
    );
  }

  group('LocalStorageImpl.tombstoneHealthSyncMetadataBySportEventId', () {
    test('stamps deletedAtMs on all rows matching the sportEventId', () async {
      await storage.saveHealthSyncMetadata(
        anEntity(healthPlatformId: 'uuid_1', sportEventId: 42),
      );
      await storage.saveHealthSyncMetadata(
        anEntity(healthPlatformId: 'uuid_2', sportEventId: 42),
      );

      await storage.tombstoneHealthSyncMetadataBySportEventId(42);

      final rows = await storage.getHealthSyncMetadata();
      expect(rows, hasLength(2));
      for (final row in rows) {
        expect(row.deletedAtMs, isNotNull);
      }
    });

    test('leaves rows for other sportEventIds untouched', () async {
      await storage.saveHealthSyncMetadata(
        anEntity(healthPlatformId: 'uuid_1', sportEventId: 42),
      );
      await storage.saveHealthSyncMetadata(
        anEntity(healthPlatformId: 'uuid_2', sportEventId: 99),
      );

      await storage.tombstoneHealthSyncMetadataBySportEventId(42);

      final rows = await storage.getHealthSyncMetadata();
      final other = rows.firstWhere((r) => r.sportEventId == 99);
      expect(other.deletedAtMs, isNull);
    });

    test('the row is not removed — still readable / containsKey', () async {
      await storage.saveHealthSyncMetadata(
        anEntity(healthPlatformId: 'uuid_1', sportEventId: 42),
      );

      await storage.tombstoneHealthSyncMetadataBySportEventId(42);

      expect(await storage.isHealthActivitySynced('uuid_1'), isTrue);
      final rows = await storage.getHealthSyncMetadata();
      expect(rows, hasLength(1));
      expect(rows.single.healthPlatformId, 'uuid_1');
    });

    test(
      're-tombstoning does not overwrite the original deletedAtMs',
      () async {
        await storage.saveHealthSyncMetadata(
          anEntity(
            healthPlatformId: 'uuid_1',
            sportEventId: 42,
            deletedAtMs: 1752800000000,
          ),
        );

        await storage.tombstoneHealthSyncMetadataBySportEventId(42);

        final rows = await storage.getHealthSyncMetadata();
        expect(rows.single.deletedAtMs, 1752800000000);
      },
    );

    test('tombstoning an unknown sportEventId is a no-op', () async {
      await storage.saveHealthSyncMetadata(
        anEntity(healthPlatformId: 'uuid_1', sportEventId: 42),
      );

      await storage.tombstoneHealthSyncMetadataBySportEventId(999);

      final rows = await storage.getHealthSyncMetadata();
      expect(rows, hasLength(1));
      expect(rows.single.deletedAtMs, isNull);
    });
  });
}
