import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_complete.dart';

abstract class GetFoodEventsOfTodayInteractor {
  Future<List<FoodEventComplete>> execute();
}