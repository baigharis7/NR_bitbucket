import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nutrenaissance_flutter/domain/interactor/foodevents/get_recent_food_items_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/sportevents/get_recent_sport_items_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/get_recent_supplement_items_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/models/supplements/supplement_simple.dart';

import '../bloc/bloc_test_mocks.mocks.dart';

FoodInfo _makeFoodInfo(int id, String nameEn, String nameEs) {
  return FoodInfo(
    'grains', id, nameEn, nameEs, 1,
    EventInfo(1, 100.0, 1, 1, null, null),
    null, null,
  );
}

void main() {
  group('GetRecentFoodItemsInteractorImpl', () {
    late MockFoodEventsRepository mockRepo;
    late GetRecentFoodItemsInteractorImpl interactor;

    setUp(() {
      mockRepo = MockFoodEventsRepository();
      interactor = GetRecentFoodItemsInteractorImpl(foodEventsRepository: mockRepo);
    });

    test('returns empty list when no events', () async {
      when(mockRepo.getRecentFoodEvents()).thenAnswer((_) async => []);
      final result = await interactor.execute();
      expect(result, isEmpty);
    });

    test('deduplicates events with same ingredient IDs and mealType', () async {
      final event1 = FoodEventComplete(
        userId: 'u1',
        eventId: 1,
        eventDate: 1000,
        mealType: 0,
        foodInfo: [_makeFoodInfo(10, 'Rice', 'Arroz')],
      );
      final event2 = FoodEventComplete(
        userId: 'u1',
        eventId: 2,
        eventDate: 900,
        mealType: 0,
        foodInfo: [_makeFoodInfo(10, 'Rice', 'Arroz')],
      );
      when(mockRepo.getRecentFoodEvents()).thenAnswer((_) async => [event1, event2]);

      final result = await interactor.execute();
      expect(result.length, 1);
    });

    test('keeps events with different mealTypes as separate', () async {
      final breakfast = FoodEventComplete(
        userId: 'u1',
        eventId: 1,
        eventDate: 1000,
        mealType: 0,
        foodInfo: [_makeFoodInfo(10, 'Rice', 'Arroz')],
      );
      final lunch = FoodEventComplete(
        userId: 'u1',
        eventId: 2,
        eventDate: 900,
        mealType: 1,
        foodInfo: [_makeFoodInfo(10, 'Rice', 'Arroz')],
      );
      when(mockRepo.getRecentFoodEvents()).thenAnswer((_) async => [breakfast, lunch]);

      final result = await interactor.execute();
      expect(result.length, 2);
    });

    test('keeps events with different ingredient IDs', () async {
      final event1 = FoodEventComplete(
        userId: 'u1',
        eventId: 1,
        eventDate: 1000,
        mealType: 0,
        foodInfo: [_makeFoodInfo(10, 'Rice', 'Arroz')],
      );
      final event2 = FoodEventComplete(
        userId: 'u1',
        eventId: 2,
        eventDate: 900,
        mealType: 0,
        foodInfo: [_makeFoodInfo(20, 'Chicken', 'Pollo')],
      );
      when(mockRepo.getRecentFoodEvents()).thenAnswer((_) async => [event1, event2]);

      final result = await interactor.execute();
      expect(result.length, 2);
    });

    test('keeps first (most recent) when duplicates exist', () async {
      final newer = FoodEventComplete(
        userId: 'u1',
        eventId: 1,
        eventDate: 2000,
        mealType: 0,
        foodName: 'Newer',
        foodInfo: [_makeFoodInfo(10, 'Rice', 'Arroz')],
      );
      final older = FoodEventComplete(
        userId: 'u1',
        eventId: 2,
        eventDate: 1000,
        mealType: 0,
        foodName: 'Older',
        foodInfo: [_makeFoodInfo(10, 'Rice', 'Arroz')],
      );
      when(mockRepo.getRecentFoodEvents()).thenAnswer((_) async => [newer, older]);

      final result = await interactor.execute();
      expect(result.length, 1);
      expect(result.first.title, 'Newer');
    });
  });

  group('GetRecentSportItemsInteractorImpl', () {
    late MockSportEventsRepository mockRepo;
    late GetRecentSportItemsInteractorImpl interactor;

    setUp(() {
      mockRepo = MockSportEventsRepository();
      interactor = GetRecentSportItemsInteractorImpl(sportEventsRepository: mockRepo);
    });

    test('returns empty list when no events', () async {
      when(mockRepo.getRecentSportEvents()).thenAnswer((_) async => []);
      final result = await interactor.execute();
      expect(result, isEmpty);
    });

    test('deduplicates events with same sport IDs', () async {
      final event1 = SportEventComplete(
        userId: 'u1',
        eventId: 1,
        eventDate: 1000,
        info: [SportEventInfo(id: 5, minutes: 30)],
      );
      final event2 = SportEventComplete(
        userId: 'u1',
        eventId: 2,
        eventDate: 900,
        info: [SportEventInfo(id: 5, minutes: 45)],
      );
      when(mockRepo.getRecentSportEvents()).thenAnswer((_) async => [event1, event2]);

      final result = await interactor.execute();
      expect(result.length, 1);
    });

    test('keeps events with different sport IDs', () async {
      final event1 = SportEventComplete(
        userId: 'u1',
        eventId: 1,
        eventDate: 1000,
        info: [SportEventInfo(id: 5, minutes: 30)],
      );
      final event2 = SportEventComplete(
        userId: 'u1',
        eventId: 2,
        eventDate: 900,
        info: [SportEventInfo(id: 10, minutes: 45)],
      );
      when(mockRepo.getRecentSportEvents()).thenAnswer((_) async => [event1, event2]);

      final result = await interactor.execute();
      expect(result.length, 2);
    });

    test('keeps first (most recent) when duplicates exist', () async {
      final newer = SportEventComplete(
        userId: 'u1',
        eventId: 1,
        eventDate: 2000,
        sportName: 'Newer',
        info: [SportEventInfo(id: 5, minutes: 30)],
      );
      final older = SportEventComplete(
        userId: 'u1',
        eventId: 2,
        eventDate: 1000,
        sportName: 'Older',
        info: [SportEventInfo(id: 5, minutes: 45)],
      );
      when(mockRepo.getRecentSportEvents()).thenAnswer((_) async => [newer, older]);

      final result = await interactor.execute();
      expect(result.length, 1);
      expect(result.first.title, 'Newer');
    });
  });

  group('GetRecentSupplementItemsInteractorImpl', () {
    late MockSupplementsRepository mockRepo;
    late GetRecentSupplementItemsInteractorImpl interactor;

    setUp(() {
      mockRepo = MockSupplementsRepository();
      interactor = GetRecentSupplementItemsInteractorImpl(supplementsRepository: mockRepo);
    });

    test('returns empty list when no events', () async {
      when(mockRepo.getRecentSupplementEvents()).thenAnswer((_) async => []);
      final result = await interactor.execute();
      expect(result, isEmpty);
    });

    test('deduplicates events with same supplement IDs', () async {
      final event1 = SupplementSimple(
        userId: 'u1',
        eventId: 1,
        eventDate: 1000,
        info: [NutriInfo(id: 3, unit: 'mg', amount: 500)],
      );
      final event2 = SupplementSimple(
        userId: 'u1',
        eventId: 2,
        eventDate: 900,
        info: [NutriInfo(id: 3, unit: 'mg', amount: 1000)],
      );
      when(mockRepo.getRecentSupplementEvents()).thenAnswer((_) async => [event1, event2]);

      final result = await interactor.execute();
      expect(result.length, 1);
    });

    test('keeps events with different supplement IDs', () async {
      final event1 = SupplementSimple(
        userId: 'u1',
        eventId: 1,
        eventDate: 1000,
        info: [NutriInfo(id: 3, unit: 'mg', amount: 500)],
      );
      final event2 = SupplementSimple(
        userId: 'u1',
        eventId: 2,
        eventDate: 900,
        info: [NutriInfo(id: 7, unit: 'mcg', amount: 100)],
      );
      when(mockRepo.getRecentSupplementEvents()).thenAnswer((_) async => [event1, event2]);

      final result = await interactor.execute();
      expect(result.length, 2);
    });

    test('keeps first (most recent) when duplicates exist', () async {
      final newer = SupplementSimple(
        userId: 'u1',
        eventId: 1,
        eventDate: 2000,
        name: 'Newer',
        info: [NutriInfo(id: 3, unit: 'mg', amount: 500)],
      );
      final older = SupplementSimple(
        userId: 'u1',
        eventId: 2,
        eventDate: 1000,
        name: 'Older',
        info: [NutriInfo(id: 3, unit: 'mg', amount: 1000)],
      );
      when(mockRepo.getRecentSupplementEvents()).thenAnswer((_) async => [newer, older]);

      final result = await interactor.execute();
      expect(result.length, 1);
      expect(result.first.name, 'Newer');
    });
  });
}
