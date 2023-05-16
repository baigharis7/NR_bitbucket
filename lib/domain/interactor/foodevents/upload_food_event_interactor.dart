import 'package:nutrenaissance_flutter/data/api/foodevents/model/upload_food_event.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_simple.dart';

abstract class UploadFoodEventInteractor {
  Future<UploadFoodEvent> execute(FoodEventSimple foodEventSimple);
}