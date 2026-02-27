import 'package:flutter/cupertino.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/food/food_favorite.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_arguments_model.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_simple.dart';

import '../../../domain/models/foodevents/food_event_complete.dart';
import '../../../domain/models/foodroutine/food_routine_event.dart';

class AddFoodEventActions {
  AddFoodEventActions();
}

class InitializeStateAction extends AddFoodEventActions {
  InitializeStateAction();
}

class RemoveFoodFromEventAction extends AddFoodEventActions {
  FoodInFavorite foodInEvent;

  RemoveFoodFromEventAction({required this.foodInEvent});
}

class AddFoodFromEventAction extends AddFoodEventActions {
  FoodInFavorite foodInEvent;

  AddFoodFromEventAction({required this.foodInEvent});
}

class UpdateFoodQuantityEventAction extends AddFoodEventActions {
  FoodInFavorite foodInEvent;

  UpdateFoodQuantityEventAction({required this.foodInEvent});
}

class UpdateFoodUnitEventAction extends AddFoodEventActions {
  FoodInFavorite foodInEvent;

  UpdateFoodUnitEventAction({required this.foodInEvent});
}

class UpdateFoodCookingMethodEventAction extends AddFoodEventActions {
  FoodInFavorite foodInEvent;

  UpdateFoodCookingMethodEventAction({required this.foodInEvent});
}

class FinishFoodEventAction extends AddFoodEventActions {
  Function onFinish;

  FinishFoodEventAction({required this.onFinish});
}

class FinishAddFoodEventAction extends AddFoodEventActions {
  FoodEventSimple foodEventSimple;
  Function onFinish;

  FinishAddFoodEventAction({required this.foodEventSimple, required this.onFinish});
}

class FinishAddFoodRoutineEventAction extends AddFoodEventActions {
  FoodRoutineEvent foodRoutineEvent;
  Function onFinish;

  FinishAddFoodRoutineEventAction({required this.foodRoutineEvent, required this.onFinish});
}

class FinishFoodRoutineAction extends AddFoodEventActions {
  Function onFinish;

  FinishFoodRoutineAction({required this.onFinish});
}

class RemoveFavoriteFoodAddFoodEventAction extends AddFoodEventActions {
  final FoodFavorite foodFavorite;
  final Function onFinish;

  RemoveFavoriteFoodAddFoodEventAction({required this.onFinish, required this.foodFavorite});
}

class FinishFoodAsFavoriteEventAction extends AddFoodEventActions {
  FoodFavorite foodFavorite;
  Function onFinish;

  FinishFoodAsFavoriteEventAction({required this.foodFavorite, required this.onFinish});
}

class AddFoodNameEventAction extends AddFoodEventActions {
  String foodName;

  AddFoodNameEventAction({required this.foodName});
}

class UpdateScheduleTimeAddFoodEventActions extends AddFoodEventActions {
  final String scheduleTime;

  UpdateScheduleTimeAddFoodEventActions({required this.scheduleTime});
}

class AddFoodArgumentModelEventAction extends AddFoodEventActions {
  FoodArgumentsModel foodArgumentsModel;

  AddFoodArgumentModelEventAction({required this.foodArgumentsModel});
}

class AddFoodMealTypeEventAction extends AddFoodEventActions {
  int mealType;

  AddFoodMealTypeEventAction({required this.mealType});
}

class ResetFoodEventInfoAction extends AddFoodEventActions {
  ResetFoodEventInfoAction();
}

class AddFoodFromFavouriteEventAction extends AddFoodEventActions {
  final FoodFavorite foodFavorite;
  AddFoodFromFavouriteEventAction({required this.foodFavorite});
}

class FinishFoodFavouriteEventAction extends AddFoodEventActions {
  Function onFinish;

  FinishFoodFavouriteEventAction({required this.onFinish});
}

class UpdateCreteDishEventAction extends AddFoodEventActions {}

class UpdateIsFavoriteEventAction extends AddFoodEventActions {}

class UpdateIsCreateRoutineEventAction extends AddFoodEventActions {}

class FinishFoodWithoutCreateDishEventAction extends AddFoodEventActions {
  final Function onFinish;
  final BuildContext context;

  FinishFoodWithoutCreateDishEventAction({required this.context, required this.onFinish});
}

class UpdateFoodConversionFactor extends AddFoodEventActions {
  final FoodInFavorite foodInEvent;

  UpdateFoodConversionFactor({required this.foodInEvent});
}

class UpdateOilUsedEventAction extends AddFoodEventActions {
  final FoodInFavorite foodInEvent;

  UpdateOilUsedEventAction({required this.foodInEvent});
}

class UpdateDaysOfWeekEventAction extends AddFoodEventActions {
  final int day;

  UpdateDaysOfWeekEventAction({required this.day});
}

class UpdateEventDateEventAction extends AddFoodEventActions {
  final DateTime dateTime;

  UpdateEventDateEventAction({required this.dateTime});
}

class UpdateFoodDataFromFavoritesAddFoodEventActions extends AddFoodEventActions {
  final FoodFavorite foodFavorite;

  UpdateFoodDataFromFavoritesAddFoodEventActions({required this.foodFavorite});
}

class UpdateFoodRoutineFromRoutines extends AddFoodEventActions {
  final FoodRoutineEvent foodRoutineEvent;

  UpdateFoodRoutineFromRoutines({required this.foodRoutineEvent});
}

class FinishFoodEventAddFoodEventActions extends AddFoodEventActions {
  Function onFinish;

  FinishFoodEventAddFoodEventActions({required this.onFinish});
}

class SwitchFavRecentTabAction extends AddFoodEventActions {
  final int tabIndex;

  SwitchFavRecentTabAction({required this.tabIndex});
}

class PrefillFoodForRoutineAction extends AddFoodEventActions {
  final FoodFavorite foodFavorite;

  PrefillFoodForRoutineAction({required this.foodFavorite});
}

class PrefillFoodForFavoriteAction extends AddFoodEventActions {
  final FoodFavorite foodFavorite;

  PrefillFoodForFavoriteAction({required this.foodFavorite});
}

class PrefillFoodForCustomizeAction extends AddFoodEventActions {
  final FoodFavorite foodFavorite;

  PrefillFoodForCustomizeAction({required this.foodFavorite});
}