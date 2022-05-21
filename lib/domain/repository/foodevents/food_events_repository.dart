import 'package:nutrenaissance_flutter/data/api/foodevents/model/upload_food_event.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_simple.dart';

abstract class FoodEventsRepository {
  Future<UploadFoodEvent> uploadFoodEvent(FoodEventSimple foodEventSimple);
  Future<void> saveFoodEvent(UploadFoodEvent uploadFoodEvent);
  Future<List<FoodEventComplete>> getAllFoodEvents();
  Future<FoodEventComplete> getLastFoodEvent();
}