import 'package:nutrenaissance_flutter/domain/models/favorites/food/meal_time.dart';

class FoodArgumentsModel {
  final MealTime mealTime;
  final DateTime selectedDateTime;
  final bool preSelectFavorite;
  final bool preSelectRoutine;

  FoodArgumentsModel({
    required this.mealTime,
    required this.selectedDateTime,
    this.preSelectFavorite = false,
    this.preSelectRoutine = false,
  });
}