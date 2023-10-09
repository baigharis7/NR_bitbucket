part of 'food_bloc.dart';

// @immutable
// abstract class FoodState {}

class FoodEventState {
  FoodsAndDrinksNamesMaster? foodNames;
  List<FoodItemMaster>? filteredFood;

  FoodEventState({this.foodNames, this.filteredFood});

  FoodEventState copyWith({FoodsAndDrinksNamesMaster? foodNames, List<FoodItemMaster>? filteredFood}) {
    return FoodEventState(foodNames: foodNames ?? this.foodNames, filteredFood: filteredFood ?? this.filteredFood);
  }
}
