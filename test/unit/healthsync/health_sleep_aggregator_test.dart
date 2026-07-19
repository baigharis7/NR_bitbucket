import 'package:flutter_test/flutter_test.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/healthsync/health_sleep_aggregator.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/healthsync/health_source_resolver.dart';

void main() {
  const aggregator = HealthSleepAggregator();

  SleepSession session({
    required DateTime start,
    required DateTime end,
    required HealthSourceCategory sourceCategory,
  }) => SleepSession(start: start, end: end, sourceCategory: sourceCategory);

  /// A lower-priority planned sleep window (e.g. phone-scheduled) plus a
  /// higher-priority actual wearable-recorded session, shaped like the
  /// real-world case this aggregator exists to resolve.
  List<SleepSession> plannedSleepWindowPlusActual({
    required DateTime plannedStart,
    required DateTime plannedEnd,
    required DateTime actualStart,
    required DateTime actualEnd,
  }) => [
    session(
      start: plannedStart,
      end: plannedEnd,
      sourceCategory: HealthSourceCategory.healthConnectApp,
    ),
    session(
      start: actualStart,
      end: actualEnd,
      sourceCategory: HealthSourceCategory.appleWatch,
    ),
  ];

  group('priority source wins over planned window', () {
    test('drops the lower-priority planned window and selects the wearable '
        'actual session', () {
      final sessions = plannedSleepWindowPlusActual(
        plannedStart: DateTime(2026, 7, 10, 22, 0),
        plannedEnd: DateTime(2026, 7, 11, 6, 0), // 8h planned window
        actualStart: DateTime(2026, 7, 10, 23, 0),
        actualEnd: DateTime(2026, 7, 11, 5, 45), // 6h45m actual
      );

      final result = aggregator.aggregate(sessions: sessions);

      expect(result.hours, closeTo(6.75, 0.001));
      expect(result.selectedCategory, HealthSourceCategory.appleWatch);
      expect(result.strategy, SleepAggregationStrategy.prioritySourceUnion);
      expect(result.discardedCount, greaterThanOrEqualTo(1));
      expect(result.sourceCount, 2);
    });
  });

  group('intra-source overlap union preserved', () {
    test('two overlapping sessions from the same selected source are unioned, '
        'not summed', () {
      final sessions = [
        session(
          start: DateTime(2026, 7, 10, 23, 0),
          end: DateTime(2026, 7, 11, 3, 0), // 4h
          sourceCategory: HealthSourceCategory.appleWatch,
        ),
        session(
          start: DateTime(2026, 7, 11, 2, 0),
          end: DateTime(2026, 7, 11, 6, 0), // 4h, overlaps 1h with above
          sourceCategory: HealthSourceCategory.appleWatch,
        ),
      ];

      final result = aggregator.aggregate(sessions: sessions);

      // Union of 23:00->03:00 and 02:00->06:00 is 23:00->06:00 = 7h.
      expect(result.hours, closeTo(7.0, 0.001));
      expect(result.selectedCategory, HealthSourceCategory.appleWatch);
      expect(result.discardedCount, 0);
      expect(result.sourceCount, 1);
    });
  });

  group('invalid filters', () {
    test('zero-duration and >16h sessions are dropped and counted, without '
        'affecting the total', () {
      final valid = session(
        start: DateTime(2026, 7, 10, 23, 0),
        end: DateTime(2026, 7, 11, 6, 0), // 7h
        sourceCategory: HealthSourceCategory.appleWatch,
      );
      final zeroDuration = session(
        start: DateTime(2026, 7, 10, 22, 0),
        end: DateTime(2026, 7, 10, 22, 0),
        sourceCategory: HealthSourceCategory.appleWatch,
      );
      final tooLong = session(
        start: DateTime(2026, 7, 9, 0, 0),
        end: DateTime(2026, 7, 9, 17, 0), // 17h > 16h max
        sourceCategory: HealthSourceCategory.appleWatch,
      );

      final result = aggregator.aggregate(
        sessions: [valid, zeroDuration, tooLong],
      );

      expect(result.hours, closeTo(7.0, 0.001));
      expect(result.selectedCategory, HealthSourceCategory.appleWatch);
      expect(result.sourceCount, 1);
      expect(result.discardedCount, 2);
    });

    test('a negative-duration session is dropped as invalid too', () {
      final valid = session(
        start: DateTime(2026, 7, 10, 23, 0),
        end: DateTime(2026, 7, 11, 6, 0), // 7h
        sourceCategory: HealthSourceCategory.appleWatch,
      );
      final negative = session(
        start: DateTime(2026, 7, 10, 22, 0),
        end: DateTime(2026, 7, 10, 21, 0),
        sourceCategory: HealthSourceCategory.appleWatch,
      );

      final result = aggregator.aggregate(sessions: [valid, negative]);

      expect(result.hours, closeTo(7.0, 0.001));
      expect(result.discardedCount, 1);
    });
  });

  group('cross-midnight', () {
    test('a single 23:00->07:00 session is counted whole as 8.0h', () {
      final sessions = [
        session(
          start: DateTime(2026, 7, 10, 23, 0),
          end: DateTime(2026, 7, 11, 7, 0),
          sourceCategory: HealthSourceCategory.appleWatch,
        ),
      ];

      final result = aggregator.aggregate(sessions: sessions);

      expect(result.hours, closeTo(8.0, 0.001));
      expect(result.selectedCategory, HealthSourceCategory.appleWatch);
      expect(result.strategy, SleepAggregationStrategy.prioritySourceUnion);
    });
  });

  group('order independence', () {
    final sessions = plannedSleepWindowPlusActual(
      plannedStart: DateTime(2026, 7, 10, 22, 0),
      plannedEnd: DateTime(2026, 7, 11, 6, 0),
      actualStart: DateTime(2026, 7, 10, 23, 0),
      actualEnd: DateTime(2026, 7, 11, 5, 45),
    );

    test('shuffled/reversed order yields identical hours, selectedCategory '
        'and counts', () {
      final forward = aggregator.aggregate(sessions: sessions);
      final reversed = aggregator.aggregate(
        sessions: sessions.reversed.toList(),
      );

      expect(reversed.hours, forward.hours);
      expect(reversed.selectedCategory, forward.selectedCategory);
      expect(reversed.sourceCount, forward.sourceCount);
      expect(reversed.discardedCount, forward.discardedCount);
      expect(reversed.strategy, forward.strategy);
    });
  });

  group('empty', () {
    test('no sessions yields hours 0.0, strategy empty, null category', () {
      final result = aggregator.aggregate(sessions: const []);

      expect(result.hours, 0.0);
      expect(result.strategy, SleepAggregationStrategy.empty);
      expect(result.selectedCategory, isNull);
      expect(result.sourceCount, 0);
      expect(result.discardedCount, 0);
    });

    test('only invalid sessions yields hours 0.0, strategy empty', () {
      final zeroDuration = session(
        start: DateTime(2026, 7, 10, 22, 0),
        end: DateTime(2026, 7, 10, 22, 0),
        sourceCategory: HealthSourceCategory.appleWatch,
      );
      final tooLong = session(
        start: DateTime(2026, 7, 9, 0, 0),
        end: DateTime(2026, 7, 9, 17, 0),
        sourceCategory: HealthSourceCategory.appleWatch,
      );

      final result = aggregator.aggregate(sessions: [zeroDuration, tooLong]);

      expect(result.hours, 0.0);
      expect(result.strategy, SleepAggregationStrategy.empty);
      expect(result.selectedCategory, isNull);
      expect(result.sourceCount, 0);
      expect(result.discardedCount, 2);
    });
  });
}
