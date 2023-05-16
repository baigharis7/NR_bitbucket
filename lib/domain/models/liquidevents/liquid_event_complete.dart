import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_complete.dart';

class LiquidEventComplete extends FoodEventComplete {
  LiquidEventComplete createLiquidEventComplete(FoodEventComplete foodEventComplete) {
    LiquidEventComplete liquidEventComplete = LiquidEventComplete();
    liquidEventComplete.userId = foodEventComplete.userId;
    liquidEventComplete.eventDate = foodEventComplete.eventDate;
    liquidEventComplete.foodInfo = foodEventComplete.foodInfo;
    liquidEventComplete.eventKcals = foodEventComplete.eventKcals;
    return liquidEventComplete;
  }
}