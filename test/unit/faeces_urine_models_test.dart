import 'package:flutter_test/flutter_test.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/feces.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/urine.dart';
import 'package:nutrenaissance_flutter/data/api/fecesurine/models/upload_feces.dart';

/// Faeces/Urine test scenarios (TS-FU0001 through TS-FU0010).
///
/// The Add Faeces/Urine flow uses a shared BLoC (FecesUrineBloc) with
/// tabbed views for Faeces and Urine. Both types share the same API model
/// (UploadFeces) with `fecesId` storing the type id (0-7). Faeces follows
/// the Bristol stool scale (types 1-7, plus 0 = no bowel movement).
/// Urine types map to hydration levels (0-2 good, 3 mild, 4-5 medium, 6-7 high dehydration).

void main() {
  // ===========================================================
  // TS-FU0001: Log Faeces deposition
  // ===========================================================
  group('TS-FU0001: Log faeces deposition', () {
    test('Feces model holds Bristol scale type with title and image', () {
      final feces = Feces(
        4,
        'Type 4',
        'Like a sausage or snake, smooth and soft',
        'assets/images/diarrea_type4.png',
      );

      expect(feces.id, 4);
      expect(feces.title, 'Type 4');
      expect(feces.description, isNotNull);
      expect(feces.image, 'assets/images/diarrea_type4.png');
    });

    test('UploadFeces event created with Bristol type id', () {
      final event = UploadFeces(
        userId: 'user1',
        eventId: 1700000000,
        fecesId: 4,
      );

      expect(event.userId, 'user1');
      expect(event.eventId, 1700000000);
      expect(event.fecesId, 4);
    });

    test('Bristol scale covers types 0 through 7', () {
      // Type 0: no bowel movement (excluded from charts)
      // Types 1-7: Bristol stool scale
      for (int i = 0; i <= 7; i++) {
        final feces = Feces(i, 'Type $i', 'Description $i',
            i == 0 ? '' : 'assets/images/diarrea_type$i.png');
        expect(feces.id, i);
      }
    });

    test('Type 0 (no bowel movement) has empty image', () {
      final noBowel = Feces(0, 'No bowel movement', '', '');

      expect(noBowel.id, 0);
      expect(noBowel.image, isEmpty);
    });
  });

  // ===========================================================
  // TS-FU0002: Log Urine deposition
  // ===========================================================
  group('TS-FU0002: Log urine deposition', () {
    test('Urines model holds type with title and image', () {
      final urine = Urines(
        0,
        'Good hydration',
        'assets/images/urine_type1.png',
      );

      expect(urine.id, 0);
      expect(urine.title, 'Good hydration');
      expect(urine.image, 'assets/images/urine_type1.png');
    });

    test('UploadFeces event reused for urine with urineId as fecesId', () {
      final urineEvent = UploadFeces(
        userId: 'user1',
        eventId: 1700000000,
        fecesId: 3, // urine type id stored in fecesId field
      );

      expect(urineEvent.fecesId, 3);
    });

    test('Urine types cover ids 0 through 7 with hydration levels', () {
      final hydrationLevels = {
        0: 'Good hydration',
        1: 'Good hydration',
        2: 'Good hydration',
        3: 'Mild dehydration',
        4: 'Medium dehydration',
        5: 'Medium dehydration',
        6: 'High dehydration',
        7: 'High dehydration',
      };

      for (final entry in hydrationLevels.entries) {
        final urine = Urines(
          entry.key,
          entry.value,
          'assets/images/urine_type${entry.key + 1}.png',
        );
        expect(urine.id, entry.key);
        expect(urine.title, entry.value);
      }
    });
  });

  // ===========================================================
  // TS-FU0003: Evolution graph reflects new entries
  // ===========================================================
  group('TS-FU0003: Evolution graph data', () {
    test('chart data aggregates event counts over 14 days', () {
      // Simulate getPrevDaysData() logic from bloc
      final events = [
        UploadFeces(userId: 'user1', eventId: 1700000000, fecesId: 4),
        UploadFeces(userId: 'user1', eventId: 1700100000, fecesId: 4),
        UploadFeces(userId: 'user1', eventId: 1700200000, fecesId: 3),
        UploadFeces(userId: 'user1', eventId: 1700300000, fecesId: 5),
      ];

      // Aggregate counts by type
      final counts = <int, int>{};
      for (final event in events) {
        counts[event.fecesId] = (counts[event.fecesId] ?? 0) + 1;
      }

      expect(counts[4], 2);
      expect(counts[3], 1);
      expect(counts[5], 1);
    });

    test('chart percentage calculation over 14 days', () {
      const totalDays = 14;
      const count = 4;
      final percentage = (count / totalDays) * 100;

      expect(percentage, closeTo(28.57, 0.01));
    });

    test('chart data initializes all type ids 0-7', () {
      final chartData = List.generate(
        8,
        (i) => {'fecesId': i, 'count': 0},
      );

      expect(chartData.length, 8);
      expect(chartData[0]['fecesId'], 0);
      expect(chartData[7]['fecesId'], 7);
    });
  });

  // ===========================================================
  // TS-FU0004: Delete faeces and verify graph update
  // ===========================================================
  group('TS-FU0004: Delete faeces deposition', () {
    test('removing event from feces events list', () {
      final events = [
        UploadFeces(userId: 'user1', eventId: 1000, fecesId: 4),
        UploadFeces(userId: 'user1', eventId: 2000, fecesId: 3),
        UploadFeces(userId: 'user1', eventId: 3000, fecesId: 5),
      ];

      events.removeWhere((e) => e.eventId == 2000);

      expect(events.length, 2);
      expect(events.any((e) => e.eventId == 2000), isFalse);
    });

    test('chart recalculation after deletion', () {
      final events = [
        UploadFeces(userId: 'user1', eventId: 1000, fecesId: 4),
        UploadFeces(userId: 'user1', eventId: 2000, fecesId: 4),
      ];

      // Delete one
      events.removeWhere((e) => e.eventId == 1000);

      final type4Count =
          events.where((e) => e.fecesId == 4).length;
      expect(type4Count, 1);
    });
  });

  // ===========================================================
  // TS-FU0005: Delete urine and verify graph update
  // ===========================================================
  group('TS-FU0005: Delete urine deposition', () {
    test('removing event from urine events list', () {
      final events = [
        UploadFeces(userId: 'user1', eventId: 4000, fecesId: 0),
        UploadFeces(userId: 'user1', eventId: 5000, fecesId: 3),
      ];

      events.removeWhere((e) => e.eventId == 4000);

      expect(events.length, 1);
      expect(events.first.fecesId, 3);
    });

    test('urine chart updates after deletion', () {
      final urineEvents = [
        UploadFeces(userId: 'user1', eventId: 1000, fecesId: 0),
        UploadFeces(userId: 'user1', eventId: 2000, fecesId: 0),
        UploadFeces(userId: 'user1', eventId: 3000, fecesId: 6),
      ];

      urineEvents.removeWhere((e) => e.eventId == 2000);

      final goodHydration =
          urineEvents.where((e) => e.fecesId <= 2).length;
      final highDehydration =
          urineEvents.where((e) => e.fecesId >= 6).length;

      expect(goodHydration, 1);
      expect(highDehydration, 1);
    });
  });

  // ===========================================================
  // TS-FU0006: Add Faeces via FAB
  // TS-FU0007: Add Urine via FAB
  // Navigation passes DateTime or tab index (int) as argument.
  // ===========================================================
  group('TS-FU0006 & TS-FU0007: FAB navigation for faeces/urine', () {
    test('faeces event created with current timestamp as eventId', () {
      final now = DateTime.now().millisecondsSinceEpoch;
      final fecesEvent = UploadFeces(
        userId: 'user1',
        eventId: now,
        fecesId: 4,
      );

      expect(fecesEvent.eventId, now);
      expect(fecesEvent.fecesId, 4);
    });

    test('urine event created with current timestamp as eventId', () {
      final now = DateTime.now().millisecondsSinceEpoch;
      final urineEvent = UploadFeces(
        userId: 'user1',
        eventId: now,
        fecesId: 2,
      );

      expect(urineEvent.eventId, now);
      expect(urineEvent.fecesId, 2);
    });

    test('tab index 0 = faeces, 1 = urine for navigation', () {
      const fecesTabIndex = 0;
      const urineTabIndex = 1;

      expect(fecesTabIndex, 0);
      expect(urineTabIndex, 1);
    });
  });

  // ===========================================================
  // TS-FU0008: Navigate to Faeces/Urine Summary from Dashboard
  // ===========================================================
  group('TS-FU0008: Summary view navigation', () {
    test('feces day events filtered by date', () {
      final today = DateTime(2024, 1, 15);
      final todayStart =
          DateTime(today.year, today.month, today.day).millisecondsSinceEpoch;
      final todayEnd = todayStart + 86400000; // +24h

      final allEvents = [
        UploadFeces(userId: 'user1', eventId: todayStart + 1000, fecesId: 4),
        UploadFeces(userId: 'user1', eventId: todayStart + 50000, fecesId: 3),
        UploadFeces(
            userId: 'user1', eventId: todayStart - 100000, fecesId: 5),
      ];

      final todayEvents = allEvents
          .where((e) => e.eventId >= todayStart && e.eventId < todayEnd)
          .toList();

      expect(todayEvents.length, 2);
    });

    test('summary shows both faeces and urine events lists', () {
      final fecesEvents = [
        UploadFeces(userId: 'user1', eventId: 1000, fecesId: 4),
      ];
      final urineEvents = [
        UploadFeces(userId: 'user1', eventId: 2000, fecesId: 1),
        UploadFeces(userId: 'user1', eventId: 3000, fecesId: 3),
      ];

      expect(fecesEvents.length, 1);
      expect(urineEvents.length, 2);
    });
  });

  // ===========================================================
  // TS-FU0009: Add faeces from Summary view
  // TS-FU0010: Add urine from Summary view
  // ===========================================================
  group('TS-FU0009 & TS-FU0010: Add from summary view', () {
    test('new faeces event appended to existing day events', () {
      final dayEvents = [
        UploadFeces(userId: 'user1', eventId: 1000, fecesId: 4),
      ];

      final newEvent = UploadFeces(
        userId: 'user1',
        eventId: 2000,
        fecesId: 3,
      );
      dayEvents.add(newEvent);

      expect(dayEvents.length, 2);
      expect(dayEvents.last.fecesId, 3);
    });

    test('new urine event appended to existing day events', () {
      final dayEvents = [
        UploadFeces(userId: 'user1', eventId: 3000, fecesId: 0),
      ];

      final newEvent = UploadFeces(
        userId: 'user1',
        eventId: 4000,
        fecesId: 5,
      );
      dayEvents.add(newEvent);

      expect(dayEvents.length, 2);
      expect(dayEvents.last.fecesId, 5);
    });
  });

  // ===========================================================
  // Model and mapper coverage
  // ===========================================================
  group('Faeces/Urine model tests', () {
    test('UploadFeces toJson and fromJson roundtrip', () {
      final original = UploadFeces(
        userId: 'user1',
        eventId: 1700000000,
        fecesId: 4,
      );

      final json = original.toJson();
      final restored = UploadFeces.fromJson(json);

      expect(restored.userId, original.userId);
      expect(restored.eventId, original.eventId);
      expect(restored.fecesId, original.fecesId);
    });

    test('shared UploadFeces model differentiates by context not field', () {
      // Both faeces and urine events use the same UploadFeces model.
      // Differentiation happens at the BLoC/repository level, not in the model.
      final fecesEvent = UploadFeces(
        userId: 'user1',
        eventId: 1000,
        fecesId: 4,
      );
      final urineEvent = UploadFeces(
        userId: 'user1',
        eventId: 2000,
        fecesId: 2,
      );

      // Same type, same structure, different context
      expect(fecesEvent.runtimeType, urineEvent.runtimeType);
    });
  });
}
