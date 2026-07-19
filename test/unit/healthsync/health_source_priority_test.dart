import 'package:flutter_test/flutter_test.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/healthsync/health_source_priority.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/healthsync/health_source_resolver.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/healthsync/health_sync_diagnostics_sanitizer.dart';

void main() {
  group('HealthSourcePriority.rank', () {
    const priority = HealthSourcePriority();

    test('returns the list index for each category', () {
      expect(priority.rank(HealthSourceCategory.appleWatch), 0);
      expect(priority.rank(HealthSourceCategory.garmin), 1);
      expect(priority.rank(HealthSourceCategory.fitbit), 2);
      expect(priority.rank(HealthSourceCategory.polar), 3);
      expect(priority.rank(HealthSourceCategory.samsungHealth), 4);
      expect(priority.rank(HealthSourceCategory.healthConnectApp), 5);
      expect(priority.rank(HealthSourceCategory.appleHealthApp), 6);
      expect(priority.rank(HealthSourceCategory.googleFit), 7);
      expect(priority.rank(HealthSourceCategory.unknown), 8);
    });

    test('unknown is ranked last', () {
      expect(
        priority.rank(HealthSourceCategory.unknown),
        HealthSourceCategory.values.length - 1,
      );
    });
  });

  group('HealthSourcePriority.highestOf', () {
    const priority = HealthSourcePriority();

    test('picks the highest-priority category regardless of order', () {
      expect(
        priority.highestOf([
          HealthSourceCategory.googleFit,
          HealthSourceCategory.appleWatch,
          HealthSourceCategory.samsungHealth,
        ]),
        HealthSourceCategory.appleWatch,
      );
    });

    test('is order-independent for a shuffled input', () {
      expect(
        priority.highestOf([
          HealthSourceCategory.samsungHealth,
          HealthSourceCategory.fitbit,
          HealthSourceCategory.googleFit,
          HealthSourceCategory.appleWatch,
          HealthSourceCategory.garmin,
        ]),
        HealthSourceCategory.appleWatch,
      );
    });

    test('is order-independent for a reversed input', () {
      expect(
        priority.highestOf([
          HealthSourceCategory.unknown,
          HealthSourceCategory.googleFit,
          HealthSourceCategory.appleHealthApp,
          HealthSourceCategory.healthConnectApp,
          HealthSourceCategory.samsungHealth,
          HealthSourceCategory.polar,
          HealthSourceCategory.fitbit,
          HealthSourceCategory.garmin,
          HealthSourceCategory.appleWatch,
        ]),
        HealthSourceCategory.appleWatch,
      );
    });

    test('picks the single category when only one is given', () {
      expect(
        priority.highestOf([HealthSourceCategory.unknown]),
        HealthSourceCategory.unknown,
      );
    });

    test('breaks ties between non-appleWatch sources deterministically', () {
      expect(
        priority.highestOf([
          HealthSourceCategory.healthConnectApp,
          HealthSourceCategory.garmin,
          HealthSourceCategory.fitbit,
        ]),
        HealthSourceCategory.garmin,
      );
    });
  });

  group('coarseSourceCategory', () {
    final cases = <HealthSourceCategory, HealthSyncSourceCategory>{
      HealthSourceCategory.appleWatch: HealthSyncSourceCategory.wearable,
      HealthSourceCategory.garmin: HealthSyncSourceCategory.wearable,
      HealthSourceCategory.fitbit: HealthSyncSourceCategory.wearable,
      HealthSourceCategory.polar: HealthSyncSourceCategory.wearable,
      HealthSourceCategory.samsungHealth: HealthSyncSourceCategory.thirdPartyApp,
      HealthSourceCategory.googleFit: HealthSyncSourceCategory.thirdPartyApp,
      HealthSourceCategory.healthConnectApp: HealthSyncSourceCategory.phone,
      HealthSourceCategory.appleHealthApp: HealthSyncSourceCategory.phone,
      HealthSourceCategory.unknown: HealthSyncSourceCategory.unknown,
    };

    cases.forEach((input, expected) {
      test('maps $input to $expected', () {
        expect(coarseSourceCategory(input), expected);
      });
    });

    test('covers every HealthSourceCategory value', () {
      expect(cases.keys.toSet(), HealthSourceCategory.values.toSet());
    });
  });
}
