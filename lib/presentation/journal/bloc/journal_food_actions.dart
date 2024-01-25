import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_complete.dart';

import '../../../domain/models/favorites/food/food_favorite.dart';

class JournalFoodActions {
  JournalFoodActions();
}

class InitializeStateAction extends JournalFoodActions {
  InitializeStateAction();
}

class HideExplainingCardAction extends JournalFoodActions {
  HideExplainingCardAction();
}

class AddFoodNameAction extends JournalFoodActions {
  String name;

  AddFoodNameAction({required this.name});
}

class AddMealTimeAction extends JournalFoodActions {
  int mealTime;

  AddMealTimeAction({required this.mealTime});
}

class FinishAddingFavoriteAction extends JournalFoodActions {
  final Function onFinish;
  final FoodEventComplete foodEvent;

  FinishAddingFavoriteAction({required this.foodEvent, required this.onFinish});
}

class RemoveFavoriteAction extends JournalFoodActions {
  final FoodFavorite? foodFavorite;
  final Function onFinish;

  RemoveFavoriteAction({required this.onFinish, required this.foodFavorite});
}