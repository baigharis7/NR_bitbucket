import 'package:flutter_test/flutter_test.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/sports_info_master.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_complete.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/step_estimation_utils.dart';

void main() {
  final sportsInfo = SportsInfoMaster(sportsInfoMaster: [
    SportInfoMaster(id: 1, en: 'Running', es: 'Correr', mets: 10),
    SportInfoMaster(id: 2, en: 'Walking', es: 'Caminar', mets: 3),
    SportInfoMaster(id: 3, en: 'Cycling', es: 'Ciclismo', mets: 8),
    SportInfoMaster(id: 4, en: 'Yoga', es: 'Yoga', mets: 2),
    SportInfoMaster(id: 5, en: 'Rest', es: 'Descanso', mets: 1),
  ]);

  SportEventComplete makeEvent({
    required List<SportEventInfo> info,
    String? source,
  }) {
    return SportEventComplete(
      userId: 'user1',
      eventId: 1,
      eventDate: DateTime.now().millisecondsSinceEpoch,
      info: info,
      source: source,
    );
  }

  group('estimateStepsFromSportEvents', () {
    test('calculates steps for a single manual running event', () {
      final events = [
        makeEvent(info: [
          SportEventInfo(id: 1, minutes: 30), // Running 10 METs, 30 min
        ]),
      ];
      // (10 - 1) * 32 * 30 = 8640
      expect(estimateStepsFromSportEvents(events, sportsInfo), 8640);
    });

    test('calculates steps for multiple activities in one event', () {
      final events = [
        makeEvent(info: [
          SportEventInfo(id: 1, minutes: 30), // Running: (10-1)*32*30 = 8640
          SportEventInfo(id: 2, minutes: 20), // Walking: (3-1)*32*20 = 1280
        ]),
      ];
      expect(estimateStepsFromSportEvents(events, sportsInfo), 8640 + 1280);
    });

    test('calculates steps across multiple events', () {
      final events = [
        makeEvent(info: [
          SportEventInfo(id: 1, minutes: 30), // 8640
        ]),
        makeEvent(info: [
          SportEventInfo(id: 3, minutes: 45), // Cycling: (8-1)*32*45 = 10080
        ]),
      ];
      expect(estimateStepsFromSportEvents(events, sportsInfo), 8640 + 10080);
    });

    test('returns 0 for activity with 1 MET (no steps)', () {
      final events = [
        makeEvent(info: [
          SportEventInfo(id: 5, minutes: 60), // Rest: 1 MET → 0 steps
        ]),
      ];
      expect(estimateStepsFromSportEvents(events, sportsInfo), 0);
    });

    test('returns 0 for empty event list', () {
      expect(estimateStepsFromSportEvents([], sportsInfo), 0);
    });

    test('returns 0 for event with no info items', () {
      final events = [makeEvent(info: [])];
      expect(estimateStepsFromSportEvents(events, sportsInfo), 0);
    });

    test('returns 0 for event with null info', () {
      final events = [
        SportEventComplete(
          userId: 'user1',
          eventId: 1,
          eventDate: DateTime.now().millisecondsSinceEpoch,
          info: null,
        ),
      ];
      expect(estimateStepsFromSportEvents(events, sportsInfo), 0);
    });

    test('skips health_connect synced events', () {
      final events = [
        makeEvent(
          source: 'health_connect',
          info: [SportEventInfo(id: 1, minutes: 30)],
        ),
      ];
      expect(estimateStepsFromSportEvents(events, sportsInfo), 0);
    });

    test('skips apple_health synced events', () {
      final events = [
        makeEvent(
          source: 'apple_health',
          info: [SportEventInfo(id: 1, minutes: 30)],
        ),
      ];
      expect(estimateStepsFromSportEvents(events, sportsInfo), 0);
    });

    test('includes manual source events', () {
      final events = [
        makeEvent(
          source: 'manual',
          info: [SportEventInfo(id: 2, minutes: 20)], // (3-1)*32*20 = 1280
        ),
      ];
      expect(estimateStepsFromSportEvents(events, sportsInfo), 1280);
    });

    test('includes null source events (legacy manual entries)', () {
      final events = [
        makeEvent(
          source: null,
          info: [SportEventInfo(id: 2, minutes: 20)], // (3-1)*32*20 = 1280
        ),
      ];
      expect(estimateStepsFromSportEvents(events, sportsInfo), 1280);
    });

    test('mixed manual and synced events only counts manual', () {
      final events = [
        makeEvent(
          source: 'manual',
          info: [SportEventInfo(id: 1, minutes: 30)], // 8640
        ),
        makeEvent(
          source: 'health_connect',
          info: [SportEventInfo(id: 1, minutes: 30)], // skipped
        ),
        makeEvent(
          source: null,
          info: [SportEventInfo(id: 2, minutes: 20)], // 1280
        ),
      ];
      expect(estimateStepsFromSportEvents(events, sportsInfo), 8640 + 1280);
    });

    test('handles unknown sport id (0 METs)', () {
      final events = [
        makeEvent(info: [SportEventInfo(id: 999, minutes: 30)]),
      ];
      expect(estimateStepsFromSportEvents(events, sportsInfo), 0);
    });

    test('low MET activity produces few steps', () {
      final events = [
        makeEvent(info: [
          SportEventInfo(id: 4, minutes: 60), // Yoga: (2-1)*32*60 = 1920
        ]),
      ];
      expect(estimateStepsFromSportEvents(events, sportsInfo), 1920);
    });
  });
}
