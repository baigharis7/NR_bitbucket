import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_complete.dart';

abstract class DeleteFoodEventInteractor {
  Future<bool> execute(String userId, int eventDate);
}