import 'package:flutter_test/flutter_test.dart';
import 'package:nutrenaissance_flutter/domain/models/healthsync/sync_health_activities_result.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_complete.dart';

void main() {
  SportEventComplete anEvent() => SportEventComplete(
    userId: 'user123',
    eventId: 1,
    eventDate: DateTime(2026, 7, 1).millisecondsSinceEpoch,
    sportName: 'Running',
    source: 'health_connect',
    eventKcals: 200,
    info: [],
  );

  group('SyncHealthActivitiesResult', () {
    test('carries the synced events and outcome', () {
      final result = SyncHealthActivitiesResult(
        syncedEvents: [anEvent()],
        outcome: SyncHealthOutcome.synced,
      );
      expect(result.syncedEvents, hasLength(1));
      expect(result.outcome, SyncHealthOutcome.synced);
    });

    test('supports const construction with an empty event list', () {
      const result = SyncHealthActivitiesResult(
        syncedEvents: [],
        outcome: SyncHealthOutcome.skippedDisabled,
      );
      expect(result.syncedEvents, isEmpty);
      expect(result.outcome, SyncHealthOutcome.skippedDisabled);
    });

    test('isSuccess is true only for synced, syncedNoData, syncedPartial', () {
      const successOutcomes = {
        SyncHealthOutcome.synced,
        SyncHealthOutcome.syncedNoData,
        SyncHealthOutcome.syncedPartial,
      };
      for (final outcome in SyncHealthOutcome.values) {
        final result = SyncHealthActivitiesResult(
          syncedEvents: const [],
          outcome: outcome,
        );
        expect(
          result.isSuccess,
          successOutcomes.contains(outcome),
          reason: 'isSuccess for $outcome',
        );
      }
    });
  });
}
