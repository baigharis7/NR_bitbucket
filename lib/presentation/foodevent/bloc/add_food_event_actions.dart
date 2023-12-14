import 'package:nutrenaissance_flutter/domain/models/favorites/food/food_favorite.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_simple.dart';

import '../../../domain/models/foodevents/food_event_complete.dart';

class AddFoodEventActions {
  AddFoodEventActions();
}

class InitializeStateAction extends AddFoodEventActions {
  InitializeStateAction();
}

class RemoveFoodFromEventAction extends AddFoodEventActions {
  FoodInEvent foodInEvent;

  RemoveFoodFromEventAction({required this.foodInEvent});
}

class AddFoodFromEventAction extends AddFoodEventActions {
  FoodInEvent foodInEvent;

  AddFoodFromEventAction({required this.foodInEvent});
}

class UpdateFoodQuantityEventAction extends AddFoodEventActions {
  FoodInEvent foodInEvent;

  UpdateFoodQuantityEventAction({required this.foodInEvent});
}

class UpdateFoodUnitEventAction extends AddFoodEventActions {
  FoodInEvent foodInEvent;

  UpdateFoodUnitEventAction({required this.foodInEvent});
}

class UpdateFoodCookingMethodEventAction extends AddFoodEventActions {
  FoodInEvent foodInEvent;

  UpdateFoodCookingMethodEventAction({required this.foodInEvent});
}

// class SelectCookingMethodAction extends AddFoodEventActions {
//   FoodInEvent foodInEvent;
//
//   SelectCookingMethodAction({required this.foodInEvent});
// }

class FinishFoodEventAction extends AddFoodEventActions {
  Function onFinish;

  FinishFoodEventAction({required this.onFinish});
}

class AddFoodNameEventAction extends AddFoodEventActions {
  String foodName;

  AddFoodNameEventAction({required this.foodName});
}

class AddFoodMealTypeEventAction extends AddFoodEventActions {
  int mealType;

  AddFoodMealTypeEventAction({required this.mealType});
}

class ReceiveFoodsInEventFromNavigationAction extends AddFoodEventActions {
  final FoodEventSimple foodEventSimple;
  ReceiveFoodsInEventFromNavigationAction({required this.foodEventSimple});
}

class ResetFoodEventInfoAction extends AddFoodEventActions {
  ResetFoodEventInfoAction();
}

class ReceiveEventDateAction extends AddFoodEventActions {
  final DateTime dateTime;

  ReceiveEventDateAction({required this.dateTime});
}

class AddFoodFromFavouriteEventAction extends AddFoodEventActions {
  final FoodFavorite foodFavorite;
  AddFoodFromFavouriteEventAction({required this.foodFavorite});
}

class FinishFoodFavouriteEventAction extends AddFoodEventActions {
  Function onFinish;

  FinishFoodFavouriteEventAction({required this.onFinish});
}

class AddFoodEventFromDetailNavigation extends AddFoodEventActions {
  final FoodEventComplete foodEventComplete;

  AddFoodEventFromDetailNavigation(this.foodEventComplete);
}