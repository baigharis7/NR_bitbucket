import 'package:flutter_test/flutter_test.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/models/liquidevents/liquid_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/models/watervents/water_event_master.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/events_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/constants.dart';

void main() {
  late EventsHelper eventsHelper;

  setUp(() {
    eventsHelper = EventsHelper();
  });

  // ── getFractionToFillKcal ───────────────────────────────────────────

  group('Calorie fraction (getFractionToFillKcal)', () {
    // TS-DASH001a
    test('returns correct fraction for normal case (500/2000 = 0.25)', () {
      expect(eventsHelper.getFractionToFillKcal(500, 2000), 0.25);
    });

    // TS-DASH001b
    test('caps at 1.0 when consumed exceeds goal', () {
      expect(eventsHelper.getFractionToFillKcal(3000, 2000), 1.0);
    });

    test('returns exactly 1.0 when consumed equals goal', () {
      expect(eventsHelper.getFractionToFillKcal(2000, 2000), 1.0);
    });

    // TS-DASH001c
    test('returns 0.0 when kcal consumed is 0', () {
      expect(eventsHelper.getFractionToFillKcal(0, 2000), 0.0);
    });

    test('returns correct fraction for partial consumption', () {
      expect(eventsHelper.getFractionToFillKcal(1500, 2000), 0.75);
    });
  });

  // ── getWaterIntakeAddition ──────────────────────────────────────────

  group('Water Intake Calculation (getWaterIntakeAddition)', () {
    test('sums water event quantities correctly', () {
      final waterEvents = [
        WaterEventMaster('user1', 1000, 1001, 0.25),
        WaterEventMaster('user1', 1000, 1002, 0.25),
        WaterEventMaster('user1', 1000, 1003, 0.25),
      ];

      final result = eventsHelper.getWaterIntakeAddition(
        waterEvents,
        <LiquidEventComplete>[],
        <FoodEventComplete>[],
      );

      expect(result, 0.75);
    });

    test('returns 0.0 for null water events', () {
      final result = eventsHelper.getWaterIntakeAddition(
        null,
        <LiquidEventComplete>[],
        <FoodEventComplete>[],
      );

      expect(result, 0.0);
    });

    test('returns 0.0 for empty water events list', () {
      final result = eventsHelper.getWaterIntakeAddition(
        <WaterEventMaster>[],
        <LiquidEventComplete>[],
        <FoodEventComplete>[],
      );

      expect(result, 0.0);
    });

    test('clamps negative total to 0', () {
      final waterEvents = [
        WaterEventMaster('user1', 1000, 1001, 0.25),
        WaterEventMaster('user1', 1000, 1002, -0.25),
        WaterEventMaster('user1', 1000, 1003, -0.25),
      ];

      final result = eventsHelper.getWaterIntakeAddition(
        waterEvents,
        <LiquidEventComplete>[],
        <FoodEventComplete>[],
      );

      expect(result, 0.0);
    });

    test('returns result rounded to 2 decimal places', () {
      final waterEvents = [
        WaterEventMaster('user1', 1000, 1001, 0.25),
        WaterEventMaster('user1', 1000, 1002, 0.25),
        WaterEventMaster('user1', 1000, 1003, 0.25),
      ];

      final result = eventsHelper.getWaterIntakeAddition(
        waterEvents,
        <LiquidEventComplete>[],
        <FoodEventComplete>[],
      );

      expect(result.toString().split('.').last.length, lessThanOrEqualTo(2));
      expect(result, 0.75);
    });

    // TS-DASH003b: food events only count TAP_WATER_ID (53)
    test('food events only count items with TAP_WATER_ID', () {
      final foodEventWithWater = FoodEventComplete(
        userId: 'user1',
        eventDate: 1000,
        eventId: 1,
        foodInfo: [
          FoodInfo(
            'group',
            Constants.TAP_WATER_ID, // id = 53 (tap water)
            'Water', 'Agua',
            1,
            EventInfo(null, 500.0, 1, null, null, null), // 500ml
            null,
            null,
          ),
          FoodInfo(
            'group',
            99, // NOT tap water
            'Apple', 'Manzana',
            1,
            EventInfo(null, 200.0, 1, null, null, null), // 200ml
            null,
            null,
          ),
        ],
      );

      final result = eventsHelper.getWaterIntakeAddition(
        null,
        <LiquidEventComplete>[],
        [foodEventWithWater],
      );

      // Only the TAP_WATER_ID item (500ml / 1000 = 0.5L) should count
      expect(result, 0.5);
    });

    // TS-DASH003c: liquid events contribute qty/1000
    test('liquid events contribute qty divided by 1000', () {
      // LiquidEventComplete extends FoodEventComplete
      final liquidEvent = FoodEventComplete(
        userId: 'user1',
        eventDate: 1000,
        eventId: 2,
        foodInfo: [
          FoodInfo(
            'group',
            10, // any id
            'Juice', 'Zumo',
            1,
            EventInfo(null, 750.0, 1, null, null, null), // 750ml
            null,
            null,
          ),
        ],
      );

      // Create LiquidEventComplete from FoodEventComplete
      final liquid = LiquidEventComplete().createLiquidEventComplete(liquidEvent);

      final result = eventsHelper.getWaterIntakeAddition(
        null,
        [liquid],
        <FoodEventComplete>[],
      );

      // 750ml / 1000 = 0.75L
      expect(result, 0.75);
    });

    // TS-DASH003a: sums water + liquid + food water sources
    test('sums water events, liquid events, and food water sources', () {
      final waterEvents = [
        WaterEventMaster('user1', 1000, 1001, 0.5), // 0.5L
      ];

      final liquidEvent = FoodEventComplete(
        userId: 'user1',
        eventDate: 1000,
        eventId: 2,
        foodInfo: [
          FoodInfo(
            'group', 10, 'Juice', 'Zumo', 1,
            EventInfo(null, 500.0, 1, null, null, null), // 500ml
            null, null,
          ),
        ],
      );
      final liquid = LiquidEventComplete().createLiquidEventComplete(liquidEvent);

      final foodWithWater = FoodEventComplete(
        userId: 'user1',
        eventDate: 1000,
        eventId: 3,
        foodInfo: [
          FoodInfo(
            'group', Constants.TAP_WATER_ID, 'Water', 'Agua', 1,
            EventInfo(null, 250.0, 1, null, null, null), // 250ml
            null, null,
          ),
        ],
      );

      final result = eventsHelper.getWaterIntakeAddition(
        waterEvents,
        [liquid],
        [foodWithWater],
      );

      // 0.5 + 0.5 + 0.25 = 1.25L
      expect(result, 1.25);
    });
  });

  // ── getWaterFractionToFillFromEvents ────────────────────────────────

  group('Water Fraction (getWaterFractionToFillFromEvents)', () {
    // TS-DASH004a
    test('returns correct ratio against total required', () {
      final waterEvents = [
        WaterEventMaster('user1', 1000, 1001, 1.0), // 1L consumed
      ];

      final result = eventsHelper.getWaterFractionToFillFromEvents(
        waterEvents,
        <LiquidEventComplete>[],
        <FoodEventComplete>[],
        2.0, // 2L required
      );

      expect(result, 0.5);
    });

    // TS-DASH004b
    test('caps at 1.0 when consumed exceeds required', () {
      final waterEvents = [
        WaterEventMaster('user1', 1000, 1001, 3.0), // 3L consumed
      ];

      final result = eventsHelper.getWaterFractionToFillFromEvents(
        waterEvents,
        <LiquidEventComplete>[],
        <FoodEventComplete>[],
        2.0, // 2L required
      );

      expect(result, 1.0);
    });

    // TS-DASH004c
    test('returns 0.0 when no water consumed', () {
      final result = eventsHelper.getWaterFractionToFillFromEvents(
        <WaterEventMaster>[],
        <LiquidEventComplete>[],
        <FoodEventComplete>[],
        2.0,
      );

      expect(result, 0.0);
    });
  });

  // ── getWeeklyDataFormatted ──────────────────────────────────────────

  group('Weekly Data Formatting (getWeeklyDataFormatted)', () {
    // TS-DASH002b
    test('returns 7 entries (one per weekday)', () {
      final result = eventsHelper.getWeeklyDataFormatted([], 2000);
      expect(result.length, 7);
    });

    test('all entries have day and kcal keys', () {
      final result = eventsHelper.getWeeklyDataFormatted([], 2000);
      for (var entry in result) {
        expect(entry.containsKey('day'), true);
        expect(entry.containsKey('kcal'), true);
      }
    });

    test('entries are sorted by weekday 1-7', () {
      final result = eventsHelper.getWeeklyDataFormatted([], 2000);
      for (var i = 0; i < result.length; i++) {
        expect(result[i]['day'], i + 1);
      }
    });

    test('returns 0 kcal fraction for days with no events', () {
      final result = eventsHelper.getWeeklyDataFormatted([], 2000);
      for (var entry in result) {
        expect(entry['kcal'], 0.0);
      }
    });

    // TS-DASH002a
    test('groups sport events by weekday and sums kcal as fraction', () {
      // Use a Monday date (weekday 1)
      // 2026-02-09 is a Monday
      final mondayMillis = DateTime(2026, 2, 9).millisecondsSinceEpoch;
      // 2026-02-10 is a Tuesday
      final tuesdayMillis = DateTime(2026, 2, 10).millisecondsSinceEpoch;

      final sportEvents = [
        SportEventComplete(
          userId: 'user1',
          eventId: 1,
          eventDate: mondayMillis,
          eventKcals: 500,
          info: [],
        ),
        SportEventComplete(
          userId: 'user1',
          eventId: 2,
          eventDate: mondayMillis,
          eventKcals: 300,
          info: [],
        ),
        SportEventComplete(
          userId: 'user1',
          eventId: 3,
          eventDate: tuesdayMillis,
          eventKcals: 200,
          info: [],
        ),
      ];

      final result = eventsHelper.getWeeklyDataFormatted(sportEvents, 2000);

      // Monday (day 1): (500 + 300) / 2000 = 0.4
      expect(result[0]['day'], 1);
      expect(result[0]['kcal'], 0.4);

      // Tuesday (day 2): 200 / 2000 = 0.1
      expect(result[1]['day'], 2);
      expect(result[1]['kcal'], 0.1);

      // Wednesday (day 3): 0 / 2000 = 0.0
      expect(result[2]['kcal'], 0.0);
    });
  });

  // ── generateWaterQuantities ─────────────────────────────────────────

  group('generateWaterQuantities', () {
    test('returns the expected water quantity options', () {
      final quantities = eventsHelper.generateWaterQuantities();
      expect(quantities, [0.2, 0.5, 0.75, 1, 1.5, 2]);
    });
  });
}
