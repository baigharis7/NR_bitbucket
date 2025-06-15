import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_complete.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';

class NutritionUtils {

  static int calculateKcal({required List<FoodEventComplete> foodEvents}) {
    int totalKcal = 0;
    for (FoodEventComplete food in foodEvents) {
      totalKcal = totalKcal + food.eventKcals.orZero();
    }
    return totalKcal;
  }

}