import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_complete.dart';

abstract class GetWeekLiquidEventsInteractor {
  Future<List<FoodEventComplete>> execute();
}