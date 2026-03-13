import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_complete.dart';

abstract class GetRecentFoodEventsInteractor {
  Future<List<FoodEventComplete>> execute();
}
