import 'package:nutrenaissance_flutter/domain/models/favorites/food/meal_time.dart';

class FoodArgumentsModel {
  final MealTime mealTime;
  final DateTime selectedDateTime;

  FoodArgumentsModel({required this.mealTime, required this.selectedDateTime});
}