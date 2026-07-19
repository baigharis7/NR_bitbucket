import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:nutrenaissance_flutter/data/local/models/sportevents/sport_event_entity.dart';
import 'package:nutrenaissance_flutter/data/repository/localstorage/local_storage_impl.dart';

void main() {
  late LocalStorageImpl storage;

  setUpAll(() {
    Hive.init(Directory.systemTemp.createTempSync('nn_sport_events_test').path);
    Hive.registerAdapter(SportEventEntityAdapter());
    Hive.registerAdapter(SportEventInfoEntityAdapter());
  });

  setUp(() async {
    storage = LocalStorageImpl();
    final box = await Hive.openBox(SportEventEntity.boxName);
    await box.clear();
  });

  tearDownAll(() async {
    await Hive.deleteFromDisk();
  });

  SportEventEntity anEvent({required int eventId, String source = 'manual'}) {
    return SportEventEntity(
      userId: 'user123',
      eventDate: DateTime(2026, 7, 1).millisecondsSinceEpoch,
      sportName: 'Running',
      info: [],
      eventKcals: 200,
      eventId: eventId,
      source: source,
    );
  }

  group('LocalStorageImpl.findSportEventByEventId', () {
    test('returns null when no local event carries the eventId', () async {
      await storage.saveSportEvent(anEvent(eventId: 1), false);

      expect(await storage.findSportEventByEventId(2), isNull);
    });

    test('finds the local event with a matching eventId', () async {
      await storage.saveSportEvent(anEvent(eventId: 42), false);

      final found = await storage.findSportEventByEventId(42);

      expect(found, isNotNull);
      expect(found!.eventId, 42);
      expect(found.source, 'manual');
    });

    test('saveSportEvent overwrites by eventId — the destructive behavior the '
        'collision guard must front-run', () async {
      await storage.saveSportEvent(
        anEvent(eventId: 7, source: 'manual'),
        false,
      );
      await storage.saveSportEvent(
        anEvent(eventId: 7, source: 'health_connect'),
        false,
      );

      final box = await Hive.openBox(SportEventEntity.boxName);
      expect(box.length, 1); // the manual event was silently replaced
      final survivor = await storage.findSportEventByEventId(7);
      expect(survivor!.source, 'health_connect');
    });
  });
}
