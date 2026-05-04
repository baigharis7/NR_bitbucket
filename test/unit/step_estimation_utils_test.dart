import 'package:flutter_test/flutter_test.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/sports_info_master.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_complete.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/step_estimation_utils.dart';

void main() {
  // Use real production sport IDs so tests exercise the actual whitelist.
  final sportsInfo = SportsInfoMaster(sportsInfoMaster: [
    // metsScaled — standard K=32
    SportInfoMaster(id: 103, en: 'Walking', es: 'Andar', mets: 3),
    SportInfoMaster(id: 61, en: 'Running', es: 'Correr (moderado)', mets: 10),
    SportInfoMaster(id: 36, en: 'Hiking', es: 'Senderismo', mets: 6),
    // metsScaled — damped
    SportInfoMaster(id: 63, en: 'Running on sand', es: 'Corriendo en la arena', mets: 8),
    SportInfoMaster(id: 81, en: 'Snowshoeing', es: 'Esquí con raquetas', mets: 7),
    SportInfoMaster(id: 19, en: 'Dancing', es: 'Baile', mets: 5),
    SportInfoMaster(id: 22, en: 'Elliptical', es: 'Elíptica', mets: 6),
    SportInfoMaster(id: 43, en: 'Jumping rope', es: 'Saltar a la comba', mets: 10),
    // fixedCadence
    SportInfoMaster(id: 84, en: 'Stair climbing', es: 'Subir escaleras', mets: 8),
    SportInfoMaster(id: 85, en: 'Stair-climbing machine', es: 'Máquina de step', mets: 7),
    SportInfoMaster(id: 0, en: 'Aerobics', es: 'Aeróbic', mets: 6),
    SportInfoMaster(id: 113, en: 'Zumba', es: 'Zumba', mets: 7),
    // Not whitelisted — should produce zero steps regardless of METs
    SportInfoMaster(id: 1, en: 'Swimming', es: 'Nadar', mets: 6),
    SportInfoMaster(id: 25, en: 'Cycling', es: 'Ciclismo', mets: 8),
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

  group('estimateStepsFromSportEvents — whitelisted metsScaled (standard K=32)', () {
    test('Walking (id 103) — (3-1)*32*30 = 1920', () {
      final events = [makeEvent(info: [SportEventInfo(id: 103, minutes: 30)])];
      expect(estimateStepsFromSportEvents(events, sportsInfo), 1920);
    });

    test('Running (id 61) — (10-1)*32*30 = 8640', () {
      final events = [makeEvent(info: [SportEventInfo(id: 61, minutes: 30)])];
      expect(estimateStepsFromSportEvents(events, sportsInfo), 8640);
    });

    test('Hiking (id 36) — (6-1)*32*60 = 9600', () {
      final events = [makeEvent(info: [SportEventInfo(id: 36, minutes: 60)])];
      expect(estimateStepsFromSportEvents(events, sportsInfo), 9600);
    });
  });

  group('estimateStepsFromSportEvents — whitelisted metsScaled (damped)', () {
    test('Running on sand (id 63, K=22) — (8-1)*22*30 = 4620', () {
      final events = [makeEvent(info: [SportEventInfo(id: 63, minutes: 30)])];
      expect(estimateStepsFromSportEvents(events, sportsInfo), 4620);
    });

    test('Snowshoeing (id 81, K=18) — (7-1)*18*60 = 6480', () {
      final events = [makeEvent(info: [SportEventInfo(id: 81, minutes: 60)])];
      expect(estimateStepsFromSportEvents(events, sportsInfo), 6480);
    });

    test('Dancing (id 19, K=22) — (5-1)*22*45 = 3960', () {
      final events = [makeEvent(info: [SportEventInfo(id: 19, minutes: 45)])];
      expect(estimateStepsFromSportEvents(events, sportsInfo), 3960);
    });

    test('Elliptical (id 22, K=25) — (6-1)*25*30 = 3750', () {
      final events = [makeEvent(info: [SportEventInfo(id: 22, minutes: 30)])];
      expect(estimateStepsFromSportEvents(events, sportsInfo), 3750);
    });

    test('Jumping rope (id 43, K=15) — (10-1)*15*10 = 1350', () {
      final events = [makeEvent(info: [SportEventInfo(id: 43, minutes: 10)])];
      expect(estimateStepsFromSportEvents(events, sportsInfo), 1350);
    });
  });

  group('estimateStepsFromSportEvents — whitelisted fixedCadence', () {
    test('Stair climbing (id 84, 70 spm) — 70*15 = 1050', () {
      final events = [makeEvent(info: [SportEventInfo(id: 84, minutes: 15)])];
      expect(estimateStepsFromSportEvents(events, sportsInfo), 1050);
    });

    test('Stair-climbing machine (id 85, 75 spm) — 75*15 = 1125', () {
      final events = [makeEvent(info: [SportEventInfo(id: 85, minutes: 15)])];
      expect(estimateStepsFromSportEvents(events, sportsInfo), 1125);
    });

    test('Aerobics (id 0, 130 spm) — 130*30 = 3900', () {
      final events = [makeEvent(info: [SportEventInfo(id: 0, minutes: 30)])];
      expect(estimateStepsFromSportEvents(events, sportsInfo), 3900);
    });

    test('Zumba (id 113, 130 spm) — 130*45 = 5850', () {
      final events = [makeEvent(info: [SportEventInfo(id: 113, minutes: 45)])];
      expect(estimateStepsFromSportEvents(events, sportsInfo), 5850);
    });
  });

  group('estimateStepsFromSportEvents — non-whitelisted sports', () {
    test('Swimming (id 1, in master file) → 0 steps', () {
      final events = [makeEvent(info: [SportEventInfo(id: 1, minutes: 60)])];
      expect(estimateStepsFromSportEvents(events, sportsInfo), 0);
    });

    test('Cycling (id 25, in master file) → 0 steps', () {
      final events = [makeEvent(info: [SportEventInfo(id: 25, minutes: 45)])];
      expect(estimateStepsFromSportEvents(events, sportsInfo), 0);
    });

    test('Unknown sport id (not in master file) → 0 steps', () {
      final events = [makeEvent(info: [SportEventInfo(id: 999, minutes: 30)])];
      expect(estimateStepsFromSportEvents(events, sportsInfo), 0);
    });
  });

  group('estimateStepsFromSportEvents — multi-sport / multi-event', () {
    test('mixed strategies in one event sum correctly', () {
      // Walking 30min: (3-1)*32*30 = 1920
      // Stair climbing 10min fixed: 70*10 = 700
      // Swimming 60min: 0 (not whitelisted)
      // Sand running 20min: (8-1)*22*20 = 3080
      final events = [
        makeEvent(info: [
          SportEventInfo(id: 103, minutes: 30),
          SportEventInfo(id: 84, minutes: 10),
          SportEventInfo(id: 1, minutes: 60),
          SportEventInfo(id: 63, minutes: 20),
        ]),
      ];
      expect(estimateStepsFromSportEvents(events, sportsInfo), 1920 + 700 + 3080);
    });

    test('multiple events sum across all entries', () {
      final events = [
        makeEvent(info: [SportEventInfo(id: 61, minutes: 30)]),  // 8640
        makeEvent(info: [SportEventInfo(id: 113, minutes: 30)]), // 130*30 = 3900
      ];
      expect(estimateStepsFromSportEvents(events, sportsInfo), 8640 + 3900);
    });
  });

  group('estimateStepsFromSportEvents — source filtering', () {
    test('skips health_connect synced events even if whitelisted', () {
      final events = [
        makeEvent(
          source: 'health_connect',
          info: [SportEventInfo(id: 61, minutes: 30)],
        ),
      ];
      expect(estimateStepsFromSportEvents(events, sportsInfo), 0);
    });

    test('skips apple_health synced events even if whitelisted', () {
      final events = [
        makeEvent(
          source: 'apple_health',
          info: [SportEventInfo(id: 61, minutes: 30)],
        ),
      ];
      expect(estimateStepsFromSportEvents(events, sportsInfo), 0);
    });

    test('manual source counted', () {
      final events = [
        makeEvent(
          source: 'manual',
          info: [SportEventInfo(id: 103, minutes: 20)], // (3-1)*32*20 = 1280
        ),
      ];
      expect(estimateStepsFromSportEvents(events, sportsInfo), 1280);
    });

    test('null source counted (legacy entries)', () {
      final events = [
        makeEvent(
          source: null,
          info: [SportEventInfo(id: 103, minutes: 20)],
        ),
      ];
      expect(estimateStepsFromSportEvents(events, sportsInfo), 1280);
    });

    test('mixed manual and synced — only manual counted', () {
      final events = [
        makeEvent(source: 'manual', info: [SportEventInfo(id: 61, minutes: 30)]),       // 8640
        makeEvent(source: 'health_connect', info: [SportEventInfo(id: 61, minutes: 30)]), // skipped
        makeEvent(source: null, info: [SportEventInfo(id: 103, minutes: 20)]),          // 1280
      ];
      expect(estimateStepsFromSportEvents(events, sportsInfo), 8640 + 1280);
    });
  });

  group('estimateStepsFromSportEvents — edge cases', () {
    test('empty event list → 0', () {
      expect(estimateStepsFromSportEvents([], sportsInfo), 0);
    });

    test('event with no info items → 0', () {
      expect(estimateStepsFromSportEvents([makeEvent(info: [])], sportsInfo), 0);
    });

    test('event with null info → 0', () {
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

    test('whitelisted metsScaled with mets=1 → 0 (no scaling possible)', () {
      final lowMetMaster = SportsInfoMaster(sportsInfoMaster: [
        SportInfoMaster(id: 103, en: 'Walking', es: 'Andar', mets: 1),
      ]);
      final events = [makeEvent(info: [SportEventInfo(id: 103, minutes: 30)])];
      expect(estimateStepsFromSportEvents(events, lowMetMaster), 0);
    });

    test('fixedCadence ignores METs entirely (still produces steps)', () {
      // Even with mets=1 the cadence-bound formula keeps producing.
      final lowMetMaster = SportsInfoMaster(sportsInfoMaster: [
        SportInfoMaster(id: 84, en: 'Stair climbing', es: 'Subir escaleras', mets: 1),
      ]);
      final events = [makeEvent(info: [SportEventInfo(id: 84, minutes: 15)])];
      expect(estimateStepsFromSportEvents(events, lowMetMaster), 1050);
    });
  });
}
