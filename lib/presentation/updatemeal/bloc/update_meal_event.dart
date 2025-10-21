part of 'update_meal_bloc.dart';

// @immutable
abstract class UpdateMealEvent {}

class InitializationUpdateMealEvent extends UpdateMealEvent {}

class MealFromArgumentUpdateMealEvent extends UpdateMealEvent {
  final FoodFavorite foodFavorite;

  MealFromArgumentUpdateMealEvent({required this.foodFavorite});
}

class UpdateNameUpdateMealEvent extends UpdateMealEvent {
  final String name;

  UpdateNameUpdateMealEvent({required this.name});
}

class UpdateMealTimeUpdateMealEvent extends UpdateMealEvent {
  final int mealTime;

  UpdateMealTimeUpdateMealEvent({required this.mealTime});
}

class UpdateIngredientsUpdateMealEvent extends UpdateMealEvent {
  final FoodInFavorite ingredient;

  UpdateIngredientsUpdateMealEvent({required this.ingredient});
}

class RemoveIngredientUpdateMealEvent extends UpdateMealEvent {
  final FoodInFavorite ingredient;

  RemoveIngredientUpdateMealEvent({required this.ingredient});
}

class UpdateIngredientAmountUpdateMealEvent extends UpdateMealEvent {
  final FoodInFavorite ingredient;

  UpdateIngredientAmountUpdateMealEvent({required this.ingredient});
}

class UpdateIngredientUnitUpdateMealEvent extends UpdateMealEvent {
  final FoodInFavorite ingredient;

  UpdateIngredientUnitUpdateMealEvent({required this.ingredient});
}

class UpdateIngredientPreparationUpdateMealEvent extends UpdateMealEvent {
  final FoodInFavorite ingredient;

  UpdateIngredientPreparationUpdateMealEvent({required this.ingredient});
}

class UpdateIngredientCookingMethodUpdateMealEvent extends UpdateMealEvent {
  final FoodInFavorite ingredient;

  UpdateIngredientCookingMethodUpdateMealEvent({required this.ingredient});
}

class UpdateIngredientOilUpdateMealEvent extends UpdateMealEvent {
  final FoodInFavorite ingredient;

  UpdateIngredientOilUpdateMealEvent({required this.ingredient});
}

class SaveUpdateMealUpdateMealEvent extends UpdateMealEvent {
  final Function onFinish;

  SaveUpdateMealUpdateMealEvent({required this.onFinish});
}

class SaveUpdateMealFavoriteUpdateMealEvent extends UpdateMealEvent {
  final Function onFinish;

  SaveUpdateMealFavoriteUpdateMealEvent({required this.onFinish});
}

class SaveUpdateMealRoutineUpdateMealEvent extends UpdateMealEvent {
  final Function onFinish;

  SaveUpdateMealRoutineUpdateMealEvent({required this.onFinish});
}