import 'package:flutter_test/flutter_test.dart';
import 'package:nutrenaissance_flutter/domain/models/watervents/water_event_master.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/models/liquidevents/liquid_event_complete.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/events_helper.dart';

void main() {
  late EventsHelper eventsHelper;

  setUp(() {
    eventsHelper = EventsHelper();
  });

  group('Water Intake Calculation (getWaterIntakeAddition)', () {
    // Simulates TS-HY0001: adding multiple glasses of water
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

    // Simulates TS-HY0002: removing more water than was added
    test('clamps negative total to 0', () {
      final waterEvents = [
        WaterEventMaster('user1', 1000, 1001, 0.25),   // add
        WaterEventMaster('user1', 1000, 1002, -0.25),  // remove
        WaterEventMaster('user1', 1000, 1003, -0.25),  // remove (goes negative)
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

      // Should be exactly 0.75, not 0.7500000001 or similar
      expect(result.toString().split('.').last.length, lessThanOrEqualTo(2));
      expect(result, 0.75);
    });
  });
}
